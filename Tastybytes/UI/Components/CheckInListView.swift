import Components
import EnvironmentModels
import Extensions
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
    @State private var scrolledID: Int?
    @State private var alertError: AlertError?
    @Binding private var scrollToTop: Int

    private let header: Header
    private let showContentUnavailableView: Bool
    private let onRefresh: () async -> Void
    private let topAnchor: Int?
    private let fetcher: Fetcher
    private let pageSize = 10

    init(
        fetcher: Fetcher,
        scrollToTop: Binding<Int>,
        onRefresh: @escaping () async -> Void,
        topAnchor: Int? = nil,
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
        initialLoadCompleted && checkIns.isEmpty && showContentUnavailableView && !isLoading
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollView {
            header
            checkInSegments
            checkInList
            if !isLoading && checkIns.isEmpty {
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

    @ViewBuilder
    private var checkInList: some View {
        LazyVStack {
            ForEach(checkIns) { checkIn in
                CheckInCardView(checkIn: checkIn, loadedFrom: getLoadedFrom)
                    .id(checkIn.id)
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

    func refresh() async {
        isRefreshing = true
        await fetchFeedItems(
            reset: true,
            onComplete: { _ in
                isRefreshing = false
                await onRefresh()
            }
        )
    }

    func deleteCheckIn(checkIn: CheckIn) async {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
            withAnimation {
                checkIns.remove(object: checkIn)
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = AlertError(title: "Error occured while trying to delete a check-in. Please try again!")
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
            await splashScreenEnvironmentModel.dismiss()
            initialLoadCompleted = true
        })
    }

    func segmentChanged() async {
        await fetchFeedItems(reset: true, onComplete: { _ in logger.notice("fetched") })
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
            guard !error.localizedDescription.contains("cancelled") else { return }
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

extension View {
    func checkInContextMenu(
        router: Router,
        profileEnvironmentModel: ProfileEnvironmentModel,
        checkIn: CheckIn,
        onCheckInUpdate: @escaping (CheckIn) -> Void,
        onDelete: @escaping (CheckIn) -> Void
    ) -> some View {
        contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileEnvironmentModel.id {
                    RouterLink(
                        "Edit",
                        systemImage: "pencil",
                        sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                            onCheckInUpdate(updatedCheckIn)
                        })
                    )
                    Button(
                        "Delete",
                        systemImage: "trash.fill",
                        role: .destructive,
                        action: { onDelete(checkIn) }
                    )
                } else {
                    RouterLink(
                        "Check-in",
                        systemImage: "pencil",
                        sheet: .newCheckIn(checkIn.product, onCreation: { checkIn in
                            router.navigate(screen: .checkIn(checkIn))
                        })
                    )
                    ReportButton(entity: .checkIn(checkIn))
                }
            }
            Divider()
            RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
            RouterLink(
                "Open Brand Owner",
                systemImage: "network",
                screen: .company(checkIn.product.subBrand.brand.brandOwner)
            )
            RouterLink(
                "Open Brand",
                systemImage: "cart",
                screen: .fetchBrand(checkIn.product.subBrand.brand)
            )
            RouterLink(
                "Open Sub-brand",
                systemImage: "cart",
                screen: .fetchSubBrand(checkIn.product.subBrand)
            )
            if let location = checkIn.location {
                RouterLink(
                    "Open Location",
                    systemImage: "network",
                    screen: .location(location)
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "Open Purchase Location",
                    systemImage: "network",
                    screen: .location(purchaseLocation)
                )
            }
            Divider()
        }
    }
}
