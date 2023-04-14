import SwiftUI

struct CheckInListView<Header>: View where Header: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel
  @State private var scrollProxy: ScrollViewProxy?
  @Binding private var scrollToTop: Int
  let header: Header
  let onRefresh: () async -> Void
  let topAnchor: String?

  init(
    _ client: Client,
    fetcher: Fetcher,
    scrollToTop: Binding<Int>,
    onRefresh: @escaping () async -> Void,
    topAnchor: String? = nil,
    @ViewBuilder header: @escaping () -> Header
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, fetcher: fetcher))
    _scrollToTop = scrollToTop
    self.topAnchor = topAnchor
    self.header = header()
    self.onRefresh = onRefresh
  }

  var body: some View {
    ScrollViewReader { proxy in
      List {
        header
        checkInsList
        if viewModel.isLoading {
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
      .confirmationDialog("Are you sure you want to delete check-in? The data will be permanently lost.",
                          isPresented: $viewModel.showDeleteCheckInConfirmationDialog,
                          titleVisibility: .visible,
                          presenting: viewModel.showDeleteConfirmationFor)
      { presenting in
        ProgressButton(
          "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
          role: .destructive,
          action: {
            await viewModel.deleteCheckIn(checkIn: presenting)
            hapticManager.trigger(.notification(.success))
          }
        )
      }
      .onChange(of: scrollToTop, perform: { _ in
        withAnimation {
          if let topAnchor {
            scrollProxy?.scrollTo(topAnchor, anchor: .top)
          } else if let first = viewModel.checkIns.first {
            scrollProxy?.scrollTo(first.id, anchor: .top)
          }
        }
      })
      .refreshable {
        await hapticManager.wrapWithHaptics {
          await viewModel.refresh()
          await onRefresh()
        }
      }
      .task {
        await viewModel.fetchActivityFeedItems(onComplete: {
          if splashScreenManager.state != .finished {
            await splashScreenManager.dismiss()
          }
        })
      }
    }
  }

  @ViewBuilder private var checkInsList: some View {
    ForEach(viewModel.uniqueCheckIns) { checkIn in
      CheckInCardView(client: viewModel.client, checkIn: checkIn, loadedFrom: getLoadedFrom)
        .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
        .listRowSeparator(.hidden)
        .id(checkIn.id)
        .contextMenu {
          ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
          RouterLink("Open Company", screen: .company(checkIn.product.subBrand.brand.brandOwner))
          RouterLink("Open Brand", screen: .fetchBrand(checkIn.product.subBrand.brand))
          RouterLink("Open Check-in", screen: .checkIn(checkIn))
          Divider()
          if checkIn.profile.id == profileManager.getId() {
            RouterLink("Edit", systemImage: "pencil", sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
              viewModel.onCheckInUpdate(updatedCheckIn)
            }))
            Button(
              "Delete",
              systemImage: "trash.fill",
              role: .destructive,
              action: { viewModel.showDeleteConfirmationFor = checkIn }
            )
          }
          ReportButton(entity: .checkIn(checkIn))
        }
        .onAppear {
          if checkIn == viewModel.checkIns.last, viewModel.isLoading != true {
            Task {
              await viewModel.fetchActivityFeedItems()
            }
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
    switch viewModel.fetcher {
    case let .profile(profile):
      return .profile(profile)
    case let .location(location):
      return .location(location)
    case .product:
      return .product
    case .activityFeed:
      return .activity(profileManager.getProfile())
    }
  }
}
