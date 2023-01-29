import SwiftUI

struct CheckInListView<Header>: View
  where Header: View
{
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @StateObject private var viewModel: ViewModel
  @State private var scrollProxy: ScrollViewProxy?
  @Binding var scrollToTop: Int
  @Binding var resetView: Int
  private let topAnchor = "top"
  let header: () -> Header

  init(
    fetcher: Fetcher,
    scrollToTop: Binding<Int>,
    resetView: Binding<Int>,
    @ViewBuilder header: @escaping () -> Header
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(fetcher: fetcher))
    _scrollToTop = scrollToTop
    _resetView = resetView
    self.header = header
  }

  var body: some View {
    ScrollViewReader { proxy in
      ZStack(alignment: .top) {
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
        }
        .task {
          viewModel.fetchActivityFeedItems(onComplete: {
            if splashScreenManager.state != .finished {
              splashScreenManager.dismiss()
            }
          })
        }
      }
    }
    .sheet(item: $viewModel.editCheckIn) { checkIn in
      NavigationStack {
        CheckInSheetView(checkIn: checkIn, onUpdate: {
          updatedCheckIn in viewModel.onCheckInUpdate(updatedCheckIn)
        })
      }
    }
  }

  @ViewBuilder
  private var checkInsList: some View {
    ForEach(viewModel.checkIns, id: \.self) { checkIn in
      CheckInCardView(checkIn: checkIn,
                      loadedFrom: .activity(profileManager.getProfile()))
        .contextMenu {
          ShareLink("Share", item: createLinkToScreen(.checkIn(id: checkIn.id)))
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
}

extension CheckInListView {
  enum Fetcher {
    case activityFeed
    case product(Product.Joined)
    case profile(Profile)
    case location(Location)
  }

  @MainActor class ViewModel: ObservableObject {
    @Published var showDeleteConfirmationFor: CheckIn? {
      didSet {
        showDeleteCheckInConfirmationDialog = true
      }
    }

    @Published var editCheckIn: CheckIn?
    @Published var showDeleteCheckInConfirmationDialog = false
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    private let pageSize = 10
    private var page = 0

    let fetcher: Fetcher

    init(fetcher: Fetcher) {
      self.fetcher = fetcher
    }

    func refresh() {
      DispatchQueue.main.async {
        self.page = 0
        self.checkIns = [CheckIn]()
        self.fetchActivityFeedItems()
      }
    }

    func deleteCheckIn(checkIn: CheckIn) {
      Task {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
          showDeleteCheckInConfirmationDialog = false
          withAnimation {
            checkIns.remove(object: checkIn)
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
      if let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) {
        DispatchQueue.main.async {
          self.checkIns[index] = checkIn
        }
      }
    }

    func fetchActivityFeedItems(onComplete: (() -> Void)? = nil) {
      let (from, to) = getPagination(page: page, size: pageSize)
      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await checkInFetcher(from: from, to: to) {
        case let .success(checkIns):
          await MainActor.run {
            self.checkIns.append(contentsOf: checkIns)
            self.page += 1
            self.isLoading = false
          }

          if let onComplete {
            onComplete()
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func checkInFetcher(from: Int, to: Int) async -> Result<[CheckIn], Error> {
      switch fetcher {
      case .activityFeed:
        return await repository.checkIn.getActivityFeed(from: from, to: to)
      case let .profile(product):
        return await repository.checkIn.getByProfileId(id: product.id, from: from, to: to)
      case let .product(product):
        return await repository.checkIn.getByProductId(id: product.id, from: from, to: to)
      case let .location(location):
        return await repository.checkIn.getByLocation(locationId: location.id, from: from, to: to)
      }
    }
  }
}
