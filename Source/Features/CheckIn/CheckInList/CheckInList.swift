import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListSegmentPicker: View {
    @Binding var showCheckInsFrom: CheckInSegment

    var body: some View {
        Picker("checkIn.segment.picker.title", selection: $showCheckInsFrom) {
            ForEach(CheckInSegment.allCases, id: \.self) { segment in
                Text(segment.label)
            }
        }
        .pickerStyle(.segmented)
        .listRowSeparator(.visible, edges: .bottom)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}

struct CheckInListLoadingIndicator: View {
    @Binding var isLoading: Bool
    @Binding var isRefreshing: Bool

    var body: some View {
        ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            .opacity(isLoading && !isRefreshing ? 1 : 0)
            .listRowSeparator(.hidden)
    }
}

@MainActor
struct CheckInList<Header>: View where Header: View {
    private let logger = Logger(category: "CheckInList")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    // Tasks
    @State private var loadingCheckInsOnAppear: Task<Void, Error>?
    // Scroll position
    @Binding private var scrollToTop: Int
    // Feed state
    @State private var refreshId = 0
    @State private var resultId: Int?
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var page = 0
    // Check-ins
    @State private var checkIns = [CheckIn]()
    @State private var showCheckInsFrom: CheckInSegment = .everyone
    @State private var currentShowCheckInsFrom: CheckInSegment = .everyone
    // Dialogs
    @State private var alertError: AlertError?
    @State private var errorContentUnavailable: AlertError?

    private let id: String
    private let header: Header
    private let showContentUnavailableView: Bool
    private let onRefresh: () async -> Void
    private let topAnchor: Int?
    private let fetcher: Fetcher
    private let pageSize = 10

    init(
        id: String,
        fetcher: Fetcher,
        scrollToTop: Binding<Int> = .constant(0),
        onRefresh: @MainActor @escaping () async -> Void = {},
        topAnchor: Int? = nil,
        showContentUnavailableView: Bool = false,
        @ViewBuilder header: @escaping () -> Header = { EmptyView() }
    ) {
        self.id = id
        self.fetcher = fetcher
        _scrollToTop = scrollToTop
        self.topAnchor = topAnchor
        self.showContentUnavailableView = showContentUnavailableView
        self.header = header()
        self.onRefresh = onRefresh
    }

    var isContentUnavailable: Bool {
        refreshId == 1 && checkIns.isEmpty && showContentUnavailableView && !isLoading
    }

    var showSegmentContentUnavailableView: Bool {
        !isLoading && checkIns.isEmpty && !isContentUnavailable && fetcher.showCheckInSegmentationPicker
    }

    private var loadedFrom: CheckInCard.LoadedFrom {
        switch fetcher {
        case let .profile(profile):
            .profile(profile)
        case let .location(location):
            .location(location)
        case .product:
            .product
        case .activityFeed:
            .activity(profileEnvironmentModel.profile)
        }
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollViewReader { proxy in
            List {
                header
                    .listRowSeparator(.hidden)
                if fetcher.showCheckInSegmentationPicker {
                    CheckInListSegmentPicker(showCheckInsFrom: $showCheckInsFrom)
                }
                CheckInListContent(checkIns: $checkIns, alertError: $alertError, loadedFrom: loadedFrom, onCheckInUpdate: onCheckInUpdate, onLoadMore: {
                    onLoadMore()
                })
                CheckInListLoadingIndicator(isLoading: $isLoading, isRefreshing: $isRefreshing)
                if showSegmentContentUnavailableView {
                    showCheckInsFrom.emptyContentView.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .listStyle(.plain)
            .defaultScrollContentBackground()
            .scrollIndicators(.hidden)
            .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if errorContentUnavailable != nil {
                    ContentUnavailableView {
                        Label("checkInList.error.failedToLoad.description", systemImage: "exclamationmark.triangle")
                    } actions: {
                        Button("labels.reload") {
                            refreshId += 1
                        }
                    }
                } else if isContentUnavailable {
                    fetcher.emptyContentView
                        .listRowSeparator(.hidden)
                }
            }
            .alertError($imageUploadEnvironmentModel.alertError)
            .alertError($alertError)
            .refreshable {
                refreshId += 1
            }
            .onChange(of: scrollToTop) {
                withAnimation {
                    if let topAnchor {
                        proxy.scrollTo(topAnchor, anchor: .top)
                    } else if let first = checkIns.first {
                        proxy.scrollTo(first.id, anchor: .top)
                    }
                }
            }
            .task(id: showCheckInsFrom) { [showCheckInsFrom] in
                if showCheckInsFrom == currentShowCheckInsFrom {
                    return
                }
                logger.info("Loading check-ins for scope: \(showCheckInsFrom.rawValue)")
                await fetchFeedItems(reset: true, onComplete: { @MainActor _ in
                    currentShowCheckInsFrom = showCheckInsFrom
                    logger.info("Loaded check-ins for scope: \(showCheckInsFrom.rawValue)")
                })
            }
            .task(id: refreshId) { [refreshId] in
                guard refreshId != resultId else {
                    logger.info("Already loaded data for \(id) with id: \(refreshId)")
                    return
                }
                if refreshId == 0 {
                    logger.info("Loading initial check-in feed data for \(id)")
                    await fetchFeedItems(onComplete: { @MainActor _ in
                        logger.info("Loading initial check-ins completed for \(id)")
                    })
                    resultId = refreshId
                    return
                }
                logger.info("Refreshing check-in feed data for \(id) with id: \(refreshId)")
                isRefreshing = true
                async let feedItemsPromise: Void = fetchFeedItems(
                    reset: true,
                    onComplete: { @MainActor _ in
                        logger.info("Refreshing check-ins completed for \(id) with id: \(refreshId)")
                    }
                )
                _ = await (onRefresh(), feedItemsPromise)
                isRefreshing = false
                resultId = refreshId
            }
            .onDisappear {
                loadingCheckInsOnAppear?.cancel()
            }
            .onChange(of: imageUploadEnvironmentModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    imageUploadEnvironmentModel.uploadedImageForCheckIn = nil
                    if let index = checkIns.firstIndex(where: { $0.id == updatedCheckIn.id }) {
                        checkIns[index] = updatedCheckIn
                    }
                }
            }
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }

    func onLoadMore() {
        guard loadingCheckInsOnAppear == nil else { return }
        loadingCheckInsOnAppear = Task {
            defer { loadingCheckInsOnAppear = nil }
            logger.info("Loading more items invoked")
            await fetchFeedItems()
        }
    }

    func fetchFeedItems(
        reset: Bool = false,
        onComplete: (@Sendable (_ checkIns: [CheckIn]) async -> Void)? = nil
    ) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: pageSize)
        isLoading = true
        errorContentUnavailable = nil
        switch await checkInFetcher(from: from, to: to) {
        case let .success(fetchedCheckIns):
            withAnimation {
                if reset {
                    checkIns = fetchedCheckIns
                } else {
                    checkIns.append(contentsOf: fetchedCheckIns)
                }
            }
            page += 1
            if let onComplete {
                await onComplete(checkIns)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            let e = AlertError(title: "checkInList.error.failedToLoad.alert")
            if checkIns.isEmpty {
                errorContentUnavailable = e
            } else {
                alertError = e
            }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }

    func checkInFetcher(from: Int, to: Int) async -> Result<[CheckIn], Error> {
        switch fetcher {
        case .activityFeed:
            await repository.checkIn.getActivityFeed(from: from, to: to)
        case let .profile(product):
            await repository.checkIn.getByProfileId(id: product.id, queryType: .paginated(from, to))
        case let .product(product):
            await repository.checkIn.getByProductId(
                id: product.id,
                segment: showCheckInsFrom,
                from: from,
                to: to
            )
        case let .location(location):
            await repository.checkIn.getByLocation(
                locationId: location.id,
                segment: showCheckInsFrom,
                from: from,
                to: to
            )
        }
    }
}

extension CheckInSegment {
    var emptyContentView: some View {
        switch self {
        case .everyone:
            ContentUnavailableView {
                Label("checkIn.segment.everyone.emptyContent.title", systemImage: "list.star")
            }
        case .friends:
            ContentUnavailableView {
                Label("checkIn.segment.friends.emptyContent.title", systemImage: "list.star")
            }
        case .you:
            ContentUnavailableView {
                Label("checkIn.segment.you.emptyContent.title", systemImage: "list.star")
            }
        }
    }
}

extension CheckInList {
    enum Fetcher {
        case activityFeed
        case product(Product.Joined)
        case profile(Profile)
        case location(Location)

        @MainActor
        @ViewBuilder
        var emptyContentView: some View {
            switch self {
            case .activityFeed:
                EmptyActivityFeedView()
            default:
                EmptyView()
            }
        }

        var showCheckInSegmentationPicker: Bool {
            switch self {
            case .location, .product:
                true
            default:
                false
            }
        }
    }
}
