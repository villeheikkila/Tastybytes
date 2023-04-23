import SwiftUI

struct CheckInListView<Header>: View where Header: View {
  enum Fetcher {
    case activityFeed
    case product(Product.Joined)
    case profile(Profile)
    case location(Location)
  }

  private let logger = getLogger(category: "CheckInListView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router
  @State private var scrollProxy: ScrollViewProxy?
  @State private var showDeleteCheckInConfirmationDialog = false
  @State private var showDeleteConfirmationFor: CheckIn? {
    didSet {
      showDeleteCheckInConfirmationDialog = true
    }
  }

  @State private var editCheckIn: CheckIn?
  @State private var checkIns = [CheckIn]()
  @State private var isLoading = false
  @State private var page = 0
  @Binding private var scrollToTop: Int

  let header: Header
  let onRefresh: () async -> Void
  let topAnchor: String?

  init(
    fetcher: Fetcher,
    scrollToTop: Binding<Int>,
    onRefresh: @escaping () async -> Void,
    topAnchor: String? = nil,
    @ViewBuilder header: @escaping () -> Header
  ) {
    self.fetcher = fetcher
    _scrollToTop = scrollToTop
    self.topAnchor = topAnchor
    self.header = header()
    self.onRefresh = onRefresh
  }

  let fetcher: Fetcher
  private let pageSize = 10

  var body: some View {
    ScrollViewReader { proxy in
      GeometryReader { geometry in
        List {
          header
          ForEach(uniqueCheckIns) { checkIn in
            let edgeInset = geometry.size.width < 450 ? 8 : (geometry.size.width - 450) / 2
            CheckInCardView(checkIn: checkIn, loadedFrom: getLoadedFrom)
              .listRowInsets(.init(top: 4, leading: edgeInset, bottom: 4, trailing: edgeInset))
              .listRowSeparator(.hidden)
              .id(checkIn.id)
              .contextMenu {
                ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
                RouterLink(
                  "Open Company",
                  systemImage: "network",
                  screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink("Open Brand", systemImage: "cart", screen: .fetchBrand(checkIn.product.subBrand.brand))
                RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink("Open Check-in", systemImage: "checkmark.circle", screen: .checkIn(checkIn))
                Divider()
                if checkIn.profile.id == profileManager.id {
                  RouterLink("Edit", systemImage: "pencil", sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                    onCheckInUpdate(updatedCheckIn)
                  }))
                  Button(
                    "Delete",
                    systemImage: "trash.fill",
                    role: .destructive,
                    action: { showDeleteConfirmationFor = checkIn }
                  )
                }
                ReportButton(entity: .checkIn(checkIn))
              }
              .onAppear {
                if checkIn == checkIns.last, isLoading != true {
                  Task {
                    await fetchActivityFeedItems()
                  }
                }
              }
          }
          if isLoading {
            ProgressView()
              .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
              .listRowSeparator(.hidden)
          }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(geometry.size.width > 450 ? .inline : .automatic)
        .onAppear {
          scrollProxy = proxy
        }
        .confirmationDialog("Are you sure you want to delete check-in? The data will be permanently lost.",
                            isPresented: $showDeleteCheckInConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: showDeleteConfirmationFor)
        { presenting in
          ProgressButton(
            "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
            role: .destructive,
            action: { await deleteCheckIn(checkIn: presenting) }
          )
        }
        .onChange(of: scrollToTop, perform: { _ in
          withAnimation {
            if let topAnchor {
              scrollProxy?.scrollTo(topAnchor, anchor: .top)
            } else if let first = checkIns.first {
              scrollProxy?.scrollTo(first.id, anchor: .top)
            }
          }
        })
        #if !targetEnvironment(macCatalyst)
        .refreshable {
          await feedbackManager.wrapWithHaptics {
            await refresh()
            await onRefresh()
          }
        }
        #endif
        .task {
          await fetchActivityFeedItems(onComplete: {
            if splashScreenManager.state != .finished {
              await splashScreenManager.dismiss()
            }
          })
        }
      }
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      RouterLink("Friends Page", systemImage: "person.2", screen: .currentUserFriends)
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouterLink("Settings Page", systemImage: "gear", screen: .settings)
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }
  }

  private var getLoadedFrom: CheckInCardView.LoadedFrom {
    switch fetcher {
    case let .profile(profile):
      return .profile(profile)
    case let .location(location):
      return .location(location)
    case .product:
      return .product
    case .activityFeed:
      return .activity(profileManager.profile)
    }
  }

  var uniqueCheckIns: [CheckIn] {
    checkIns.unique(selector: { $0.id == $1.id })
  }

  func refresh() async {
    page = 0
    checkIns = [CheckIn]()
    await fetchActivityFeedItems()
  }

  func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
  }

  func deleteCheckIn(checkIn: CheckIn) async {
    switch await repository.checkIn.delete(id: checkIn.id) {
    case .success:
      withAnimation {
        checkIns.remove(object: checkIn)
      }
      feedbackManager.trigger(.notification(.success))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("deleting check-in failed: \(error.localizedDescription)")
    }
  }

  func onCheckInUpdate(_ checkIn: CheckIn) {
    guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
    checkIns[index] = checkIn
  }

  func fetchActivityFeedItems(onComplete: (() async -> Void)? = nil) async {
    let (from, to) = getPagination(page: page, size: pageSize)
    isLoading = true

    switch await checkInFetcher(from: from, to: to) {
    case let .success(checkIns):
      withAnimation {
        self.checkIns.append(contentsOf: checkIns)
      }
      page += 1
      isLoading = false

      if let onComplete {
        await onComplete()
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching check-ins failed: \(error.localizedDescription)")
    }
  }

  func checkInFetcher(from: Int, to: Int) async -> Result<[CheckIn], Error> {
    switch fetcher {
    case .activityFeed:
      return await repository.checkIn.getActivityFeed(from: from, to: to)
    case let .profile(product):
      return await repository.checkIn.getByProfileId(id: product.id, queryType: .paginated(from, to))
    case let .product(product):
      return await repository.checkIn.getByProductId(id: product.id, from: from, to: to)
    case let .location(location):
      return await repository.checkIn.getByLocation(locationId: location.id, from: from, to: to)
    }
  }
}
