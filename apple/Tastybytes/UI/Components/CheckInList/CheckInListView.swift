import SwiftUI

struct CheckInListView<Header>: View
  where Header: View
{
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollProxy: ScrollViewProxy?
  @Binding private var scrollToTop: Int
  @Binding private var resetView: Int
  private let topAnchor = "top"
  let header: () -> Header
  let onRefresh: () -> Void

  init(
    _ client: Client,
    fetcher: Fetcher,
    scrollToTop: Binding<Int>,
    resetView: Binding<Int>,
    onRefresh: @escaping () -> Void,
    @ViewBuilder header: @escaping () -> Header
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, fetcher: fetcher))
    _scrollToTop = scrollToTop
    _resetView = resetView
    self.header = header
    self.onRefresh = onRefresh
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        Rectangle()
          .frame(height: 0)
          .id(topAnchor)
        header()
        LazyVStack(spacing: 8) {
          checkInsList
        }
        if viewModel.isLoading {
          ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
        }
      }
      .onAppear {
        scrollProxy = proxy
      }
      .confirmationDialog("Delete Check-in Confirmation",
                          isPresented: $viewModel.showDeleteCheckInConfirmationDialog,
                          presenting: viewModel.showDeleteConfirmationFor) { presenting in
        Button(
          "Delete the check-in for \(presenting.product.getDisplayName(.fullName))",
          role: .destructive,
          action: {
            viewModel.deleteCheckIn(checkIn: presenting)
          }
        )
      }

      .onChange(of: scrollToTop, perform: { _ in
        withAnimation {
          scrollProxy?.scrollTo(topAnchor, anchor: .top)
        }
      })
      .onChange(of: resetView, perform: { _ in
        viewModel.refresh()
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
        CheckInSheetView(viewModel.client, checkIn: checkIn, onUpdate: {
          updatedCheckIn in viewModel.onCheckInUpdate(updatedCheckIn)
        })
      }
    }
  }

  @ViewBuilder
  private var checkInsList: some View {
    ForEach(viewModel.checkIns, id: \.self) { checkIn in
      CheckInCardView(client: viewModel.client, checkIn: checkIn,
                      loadedFrom: getLoadedFrom)
        .contextMenu {
          ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
          Divider()
          if checkIn.profile.id == profileManager.getId() {
            Button(action: {
              viewModel.editCheckIn = checkIn
            }) {
              Label("Edit", systemImage: "pencil")
            }

            Button(action: {
              viewModel.showDeleteConfirmationFor = checkIn
            }) {
              Label("Delete", systemImage: "trash.fill")
            }
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
        Image(systemName: "person.2").imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Image(systemName: "gear").imageScale(.large)
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
