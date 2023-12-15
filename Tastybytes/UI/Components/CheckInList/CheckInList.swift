import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInList<Header>: View where Header: View {
    private let logger = Logger(category: "CheckInListView")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    // Tasks
    @State private var loadingCheckInsOnAppear: Task<Void, Error>?
    // Scroll position
    @Binding private var scrollToTop: Int
    @State private var scrolledID: Int?
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
    @State private var showDeleteCheckInConfirmationDialog = false
    @State private var showDeleteConfirmationFor: CheckIn? {
        didSet {
            showDeleteCheckInConfirmationDialog = true
        }
    }

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
        scrollToTop: Binding<Int>,
        onRefresh: @escaping () async -> Void,
        topAnchor: Int? = nil,
        showContentUnavailableView: Bool = false,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.id = id
        self.fetcher = fetcher
        _scrollToTop = scrollToTop
        self.topAnchor = topAnchor
        self.showContentUnavailableView = showContentUnavailableView
        self.header = header()
        self.onRefresh = onRefresh
    }

    var initialLoadCompleted: Bool {
        refreshId == 1
    }

    var isContentUnavailable: Bool {
        initialLoadCompleted && checkIns.isEmpty && showContentUnavailableView && !isLoading
    }

    var showSegmentContentUnavailableView: Bool {
        !isLoading && checkIns.isEmpty && !isContentUnavailable && fetcher.showCheckInSegmentationPicker
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollView {
            header
            checkInSegments
            checkInList
            if showSegmentContentUnavailableView {
                showCheckInsFrom.emptyContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .scrollPosition(id: $scrolledID)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .background {
            fetcher.emptyContentView.opacity(isContentUnavailable ? 1 : 0)
        }
        .alertError($imageUploadEnvironmentModel.alertError)
        .alertError($alertError)
        .onChange(of: scrollToTop) {
            withAnimation {
                if let topAnchor {
                    scrolledID = topAnchor
                } else if let first = checkIns.first {
                    scrolledID = first.id
                }
            }
        }
        .task(id: refreshId) { [refreshId] in
            guard refreshId != resultId else {
                logger.info("Already loaded data for \(id) with id: \(refreshId)")
                return
            }
            if refreshId == 0 {
                logger.info("Loading initial check-in feed data for \(id)")
                await fetchFeedItems(onComplete: { _ in
                    logger.info("Loading initial check-ins completed for \(id)")
                    splashScreenEnvironmentModel.dismiss()
                })
                resultId = refreshId
                return
            }
            logger.info("Refreshing check-in feed data for \(id) with id: \(refreshId)")
            isRefreshing = true
            async let onRefreshPromise: Void = onRefresh()
            async let feedItemsPromise: Void = fetchFeedItems(
                reset: true,
                onComplete: { _ in
                    logger.info("Refreshing check-ins completed for \(id) with id: \(refreshId)")
                }
            )
            _ = (await onRefreshPromise, await feedItemsPromise)
            isRefreshing = false
            resultId = refreshId
        }
        .task(id: showCheckInsFrom) { [showCheckInsFrom] in
            if showCheckInsFrom == currentShowCheckInsFrom {
                return
            }
            logger.info("Loading check-ins for scope: \(showCheckInsFrom.rawValue)")
            await fetchFeedItems(reset: true, onComplete: { _ in
                currentShowCheckInsFrom = showCheckInsFrom
                logger.info("Loaded check-ins for scope: \(showCheckInsFrom.rawValue)")
            })
        }
        .onDisappear {
            loadingCheckInsOnAppear?.cancel()
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            refreshId += 1
        }
        #endif
        .onChange(of: imageUploadEnvironmentModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    imageUploadEnvironmentModel.uploadedImageForCheckIn = nil
                    if let index = checkIns.firstIndex(where: { $0.id == updatedCheckIn.id }) {
                        checkIns[index] = updatedCheckIn
                    }
                }
            }
    }

    @ViewBuilder
    private var checkInList: some View {
        LazyVStack {
            ForEach(checkIns) { checkIn in
                CheckInListCard(
                    checkIn: checkIn,
                    onUpdate: onCheckInUpdate,
                    onDelete: deleteCheckIn
                )
                .id(checkIn.id)
                .onAppear {
                    if checkIn == checkIns.last, isLoading != true {
                        loadingCheckInsOnAppear = Task {
                            await fetchFeedItems()
                        }
                    }
                }
            }
            ProgressView()
                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                .opacity(isLoading && !isRefreshing ? 1 : 0)
        }
        .scrollTargetLayout()
    }

    @ViewBuilder
    private var checkInSegments: some View {
        if fetcher.showCheckInSegmentationPicker {
            Picker("Show check-ins from", selection: $showCheckInsFrom) {
                ForEach(CheckInSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("Friends Page", systemImage: "person.2", screen: .currentUserFriends)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("Settings Page", systemImage: "gear", screen: .settings)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }

    private var getLoadedFrom: CheckInCard.LoadedFrom {
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

    func deleteCheckIn(_ checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            withAnimation {
                checkIns.remove(object: checkIn)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = AlertError(title: "Error occured while trying to delete a check-in. Please try again!")
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }

    func fetchFeedItems(reset: Bool = false, onComplete: ((_ checkIns: [CheckIn]) async -> Void)? = nil) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: pageSize)
        isLoading = true
        switch await checkInFetcher(from: from, to: to) {
        case let .success(fetchedCheckIns):
            await MainActor.run {
                withAnimation {
                    if reset {
                        self.checkIns = fetchedCheckIns
                    } else {
                        self.checkIns.append(contentsOf: fetchedCheckIns)
                    }
                }
            }
            page += 1
            if let onComplete {
                await onComplete(checkIns)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = AlertError(title: "Error occured while trying to load check-ins")
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
                Label("Be first to check-in!", systemImage: "list.star")
            }
        case .friends:
            ContentUnavailableView {
                Label("No check-ins from friends", systemImage: "list.star")
            }
        case .you:
            ContentUnavailableView {
                Label("You haven't check-in yet", systemImage: "list.star")
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

        @ViewBuilder
        var emptyContentView: some View {
            switch self {
            case .activityFeed:
                EmptyActivityFeed()
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
