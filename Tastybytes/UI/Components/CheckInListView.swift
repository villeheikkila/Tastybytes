import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "CheckInListView")

extension CheckInListView {
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

struct CheckInListView<Header>: View where Header: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showDeleteCheckInConfirmationDialog = false
    @State private var showDeleteConfirmationFor: CheckIn? {
        didSet {
            showDeleteCheckInConfirmationDialog = true
        }
    }

    @State private var checkIns = [CheckIn]()
    @State private var isLoading = false
    @State private var initialLoadCompleted = false
    @State private var page = 0
    @State private var showEmptyView = false
    @State private var isRefreshing = false
    @State private var showCheckInsFrom: CheckInSegment = .everyone
    @Binding private var scrollToTop: Int

    private let header: Header
    private let showContentUnavailableView: Bool
    private let onRefresh: () async -> Void
    private let topAnchor: String?
    private let fetcher: Fetcher
    private let pageSize = 5

    init(
        fetcher: Fetcher,
        scrollToTop: Binding<Int>,
        onRefresh: @escaping () async -> Void,
        topAnchor: String? = nil,
        showContentUnavailableView: Bool = false,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.fetcher = fetcher
        _scrollToTop = scrollToTop
        self.topAnchor = topAnchor
        self.showContentUnavailableView = showContentUnavailableView
        self.header = header()
        self.onRefresh = onRefresh
    }

    var isContentUnavailable: Bool {
        initialLoadCompleted && checkIns.isEmpty && showContentUnavailableView
    }

    var body: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                List {
                    header
                    if fetcher.showCheckInSegmentationPicker {
                        Picker("Show check-ins from", selection: $showCheckInsFrom) {
                            ForEach(CheckInSegment.allCases, id: \.self) { segment in
                                Text(segment.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowSeparator(.hidden)

                        if !isLoading && uniqueCheckIns.isEmpty {
                            showCheckInsFrom.emptyContentView
                                .listRowSeparator(.hidden)
                        }
                    }
                    ForEach(uniqueCheckIns) { checkIn in
                        let edgeInset = geometry.size.width < 450 ? 8 : (geometry.size.width - 450) / 2
                        CheckInCardView(checkIn: checkIn, loadedFrom: getLoadedFrom)
                            .listRowInsets(.init(top: 4, leading: edgeInset, bottom: 4, trailing: edgeInset))
                            .listRowSeparator(.hidden)
                            .checkInContextMenu(
                                router: router,
                                profileEnvironmentModel: profileEnvironmentModel,
                                checkIn: checkIn,
                                onCheckInUpdate: { updatedCheckIn in
                                    onCheckInUpdate(updatedCheckIn)
                                },
                                onDelete: { checkIn in
                                    showDeleteConfirmationFor = checkIn
                                }
                            )
                            .if(showDeleteConfirmationFor == checkIn, transform: { view in
                                view.confirmationDialog(
                                    "Are you sure you want to delete check-in? The data will be permanently lost.",
                                    isPresented: $showDeleteCheckInConfirmationDialog,
                                    titleVisibility: .visible,
                                    presenting: showDeleteConfirmationFor
                                ) { presenting in
                                    ProgressButton(
                                        "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
                                        role: .destructive,
                                        action: { await deleteCheckIn(checkIn: presenting) }
                                    )
                                }
                            })
                            .onAppear {
                                if checkIn == checkIns.last, isLoading != true {
                                    Task {
                                        await fetchFeedItems()
                                    }
                                }
                            }
                    }
                    if isLoading && !isRefreshing {
                        ProgressView()
                            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .onAppear {
                    scrollProxy = proxy
                }
                .background {
                    if isContentUnavailable {
                        fetcher.emptyContentView
                    }
                }
                .onChange(of: scrollToTop) {
                    withAnimation {
                        if let topAnchor {
                            scrollProxy?.scrollTo(topAnchor, anchor: .top)
                        } else if let first = checkIns.first {
                            scrollProxy?.scrollTo(first.id, anchor: .top)
                        }
                    }
                }
                .onChange(of: showCheckInsFrom) {
                    Task {
                        await segmentChanged()
                    }
                }
                #if !targetEnvironment(macCatalyst)
                .refreshable {
                    await refresh()
                }
                #endif
                .task {
                        await getInitialData()
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

    private var getLoadedFrom: CheckInCardView.LoadedFrom {
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

    var uniqueCheckIns: [CheckIn] {
        checkIns.unique(selector: { $0.id == $1.id })
    }

    func refresh() async {
        isRefreshing = true
        page = 0
        checkIns = [CheckIn]()
        feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        await fetchFeedItems(onComplete: { _ in feedbackEnvironmentModel.trigger(.impact(intensity: .high)) })
        isRefreshing = false
        await onRefresh()
    }

    func deleteCheckIn(checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            withAnimation {
                checkIns.remove(object: checkIn)
            }
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }

    func getInitialData() async {
        guard !initialLoadCompleted else { return }
        await fetchFeedItems(onComplete: { _ in
            if splashScreenEnvironmentModel.state != .finished {
                await splashScreenEnvironmentModel.dismiss()
                initialLoadCompleted = true
            }
        })
    }

    func segmentChanged() async {
        page = 0
        checkIns = [CheckIn]()
        await fetchFeedItems(onComplete: { _ in logger.notice("fetched") })
    }

    func fetchFeedItems(onComplete: ((_ checkIns: [CheckIn]) async -> Void)? = nil) async {
        let (from, to) = getPagination(page: page, size: pageSize)
        isLoading = true

        switch await checkInFetcher(from: from, to: to) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    self.checkIns.append(contentsOf: checkIns)
                }
            }
            page += 1
            isLoading = false

            if let onComplete {
                await onComplete(checkIns)
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
        }
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
                Label("Be first to check-in!", systemImage: "list.start")
            }
        case .friends:
            ContentUnavailableView {
                Label("No check-ins from friends", systemImage: "list.start")
            }
        case .you:
            ContentUnavailableView {
                Label("You haven't check-in yet", systemImage: "list.start")
            }
        }
    }
}
