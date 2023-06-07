import SwiftUI

struct CheckInListView<Header, Content>: View where Header: View, Content: View {
  enum Fetcher {
    case activityFeed
    case product(Product.Joined)
    case profile(Profile)
    case location(Location)
  }

  private let logger = getLogger(category: "CheckInListView")
  @Environment(Repository.self) private var repository
  @Environment(ProfileManager.self) private var profileManager
  @Environment(SplashScreenManager.self) private var splashScreenManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @EnvironmentObject private var router: Router
  @Environment(ImageUploadManager.self) private var imageUploadManager
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
  @State private var initialLoadCompleted = false
  @State private var page = 0
  @State private var showEmptyView = false
  @Binding private var scrollToTop: Int

  private let header: Header
  private let emptyView: Content
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
    @ViewBuilder emptyView: @escaping () -> Content,
    @ViewBuilder header: @escaping () -> Header
  ) {
    self.fetcher = fetcher
    _scrollToTop = scrollToTop
    self.topAnchor = topAnchor
      self.showContentUnavailableView = showContentUnavailableView
    self.header = header()
    self.emptyView = emptyView()
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
          if showEmptyView {
            emptyView
          }
          ForEach(uniqueCheckIns) { checkIn in
            let edgeInset = geometry.size.width < 450 ? 8 : (geometry.size.width - 450) / 2
            CheckInCardView(checkIn: checkIn, loadedFrom: getLoadedFrom)
              .listRowInsets(.init(top: 4, leading: edgeInset, bottom: 4, trailing: edgeInset))
              .listRowSeparator(.hidden)
              .id(checkIn.id)
              .contextMenu {
                ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
                Divider()
                RouterLink(
                  "Open Company",
                  systemSymbol: .network,
                  screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink("Open Brand", systemSymbol: .cart, screen: .fetchBrand(checkIn.product.subBrand.brand))
                RouterLink(
                  "Open Sub-brand",
                  systemSymbol: .cart,
                  screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                RouterLink("Open Product", systemSymbol: .grid, screen: .product(checkIn.product))
                RouterLink("Open Check-in", systemSymbol: .checkmarkCircle, screen: .checkIn(checkIn))
                Divider()
                if checkIn.profile.id == profileManager.id {
                  RouterLink("Edit", systemSymbol: .pencil, sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                    onCheckInUpdate(updatedCheckIn)
                  }))
                  Button(
                    "Delete",
                    systemSymbol: .trashFill,
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
        .onAppear {
          scrollProxy = proxy
        }
        .background {
            if isContentUnavailable {
                ContentUnavailableView("Activity feed is empty, add friends or check-ins!", systemImage: "list.star")
            }
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
        .onChange(of: scrollToTop) {
          withAnimation {
            if let topAnchor {
              scrollProxy?.scrollTo(topAnchor, anchor: .top)
            } else if let first = checkIns.first {
              scrollProxy?.scrollTo(first.id, anchor: .top)
            }
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
        .onChange(of: imageUploadManager.uploadedImageForCheckIn) { _, newValue in
          if let updatedCheckIn = newValue {
            imageUploadManager.uploadedImageForCheckIn = nil
            if let index = checkIns.firstIndex(where: { $0.id == updatedCheckIn.id }) {
              checkIns[index] = updatedCheckIn
            }
          }
        }
      }
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      RouterLink("Friends Page", systemSymbol: .person2, screen: .currentUserFriends)
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouterLink("Settings Page", systemSymbol: .gear, screen: .settings)
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
    feedbackManager.trigger(.impact(intensity: .low))
    await fetchActivityFeedItems(onComplete: { _ in feedbackManager.trigger(.impact(intensity: .high)) })
    await onRefresh()
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

  func getInitialData() async {
    guard !initialLoadCompleted else { return }
    await fetchActivityFeedItems(onComplete: { checkIns in
      if splashScreenManager.state != .finished {
        await splashScreenManager.dismiss()
        initialLoadCompleted = true
      }
    })
  }

  func fetchActivityFeedItems(onComplete: ((_ checkIns: [CheckIn]) async -> Void)? = nil) async {
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
        await onComplete(checkIns)
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
