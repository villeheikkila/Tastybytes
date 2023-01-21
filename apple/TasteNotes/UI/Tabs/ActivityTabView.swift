import SwiftUI

struct SimpleCheckIn {
  let name: String
  let subBrandName: String
  let brandName: String
  let companyName: String
  let rating: Double
  let creator: String
}

struct ActivityTabView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
  @StateObject private var router = Router()
  @Binding var backToRoot: Tab

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
        InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, initialLoad: {
          viewModel.fetchActivityFeedItems(onComplete: {
            if splashScreenManager.state != .finished {
              splashScreenManager.dismiss()
            }
          })
        }, loadMore: {
          viewModel.fetchActivityFeedItems()
        }, refresh: {
          viewModel.refresh()
        }, content: {
          content in
          CheckInCardView(checkIn: content,
                          loadedFrom: .activity(profileManager.getProfile()),
                          onDelete: viewModel.onCheckInDelete,
                          onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn) })
        }, header: {
          EmptyView()
        })
        .navigationTitle("Activity")
        .toolbar {
          toolbarContent
        }
        .onAppear {
          router.reset()
        }
        .onChange(of: $backToRoot.wrappedValue) { backToRoot in
          if backToRoot == .activity {
            router.reset()
          }
        }
      }
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
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

extension ActivityTabView {
  class ViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    let pageSize = 10
    var page = 0

    func refresh() {
      DispatchQueue.main.async {
        self.page = 0
        self.checkIns = [CheckIn]()
        self.fetchActivityFeedItems()
      }
    }

    func onCheckInDelete(checkIn: CheckIn) {
      checkIns.remove(object: checkIn)
    }

    func onCheckInUpdate(checkIn: CheckIn) {
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

        switch await repository.checkIn.getActivityFeed(from: from, to: to) {
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
  }
}
