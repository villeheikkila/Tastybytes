import SwiftUI

struct CheckInListView<Header>: View
  where Header: View
{
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var hapticManager: HapticManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollProxy: ScrollViewProxy?
  @Binding private var scrollToTop: Int
  let header: () -> Header
  let onRefresh: () -> Void
  let topAnchor: String?

  init(
    _ client: Client,
    fetcher: Fetcher,
    scrollToTop: Binding<Int>,
    onRefresh: @escaping () -> Void,
    topAnchor: String? = nil,
    @ViewBuilder header: @escaping () -> Header
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, fetcher: fetcher))
    _scrollToTop = scrollToTop
    self.topAnchor = topAnchor
    self.header = header
    self.onRefresh = onRefresh
  }

  var body: some View {
    ScrollViewReader { proxy in
      List {
        header()
        checkInsList
        if viewModel.isLoading {
          ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
        }
      }
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      .onAppear {
        scrollProxy = proxy
      }
      .confirmationDialog("Delete Check-in Confirmation",
                          isPresented: $viewModel.showDeleteCheckInConfirmationDialog,
                          presenting: viewModel.showDeleteConfirmationFor)
      { presenting in
        Button(
          "Delete the check-in for \(presenting.product.getDisplayName(.fullName))",
          role: .destructive,
          action: {
            viewModel.deleteCheckIn(checkIn: presenting)
            hapticManager.trigger(of: .notification(.success))
          }
        )
      }
      .onChange(of: scrollToTop, perform: { _ in
        if let first = viewModel.checkIns.first {
          withAnimation {
            if let topAnchor {
              scrollProxy?.scrollTo(topAnchor, anchor: .top)
            } else {
              scrollProxy?.scrollTo(first.id, anchor: .top)
            }
          }
        }
      })
      .refreshable {
        viewModel.refresh()
        onRefresh()
      }
      .task {
        viewModel.fetchActivityFeedItems(onComplete: {
          if splashScreenManager.state != .finished {
            splashScreenManager.dismiss()
          }
        })
      }
    }
    .sheet(item: $viewModel.editCheckIn) { checkIn in
      NavigationStack {
        CheckInSheet(viewModel.client, checkIn: checkIn, onUpdate: { updatedCheckIn in
          viewModel.onCheckInUpdate(updatedCheckIn)
        })
      }
    }
  }

  @ViewBuilder
  private var checkInsList: some View {
    ForEach(viewModel.uniqueCheckIns) { checkIn in
      CheckInCardView(client: viewModel.client, checkIn: checkIn,
                      loadedFrom: getLoadedFrom)
        .listRowInsets(.init(top: 4,
                             leading: 8,
                             bottom: 4,
                             trailing: 8))
        .listRowSeparator(.hidden)
        .id(checkIn.id)
        .contextMenu {
          ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
          Divider()
          if checkIn.profile.id == profileManager.getId() {
            Button(action: { viewModel.editCheckIn = checkIn }, label: {
              Label("Edit", systemImage: "pencil")
            })
            Button(role: .destructive, action: { viewModel.showDeleteConfirmationFor = checkIn }, label: {
              Label("Delete", systemImage: "trash.fill")
            })
          }
        }
        .onAppear {
          if checkIn == viewModel.checkIns.last, viewModel.isLoading != true {
            viewModel.fetchActivityFeedItems()
          }
        }
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      NavigationLink(value: Route.currentUserFriends) {
        Label("Friends Page", systemImage: "person.2")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Label("Settings Page", systemImage: "gear")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      }
    }
  }

  var getLoadedFrom: CheckInCardView.LoadedFrom {
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
