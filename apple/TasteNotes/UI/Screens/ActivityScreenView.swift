import SwiftUI

struct SimpleCheckIn {
    let name: String
    let subBrandName: String
    let brandName: String
    let companyName: String
    let rating: Double
    let creator: String
}

struct ActivityScreenView: View {
    let profile: Profile
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var splashScreenManager: SplashScreenManager

    var body: some View {
        InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, initialLoad: {
            viewModel.loadAndDismissSplashScreen(splashScreenState: splashScreenManager.state, dismissSplashScreen: {
                splashScreenManager.dismiss()
            })
        }, loadMore: {
            viewModel.fetchActivityFeedItems()
        }, refresh: {
            viewModel.refresh()
        }, content: {
            content in
            CheckInCardView(checkIn: content,
                            loadedFrom: .activity(profile),
                            onDelete: viewModel.onCheckInDelete,
                            onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn) }
            )
        }, header: {
            EmptyView()
        })
    }
}

extension ActivityScreenView {
    class ViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var isLoading = false
        let pageSize = 5
        var page = 0

        func refresh() {
            page = 0
            checkIns = []
            fetchActivityFeedItems()
        }

        func onCheckInDelete(checkIn: CheckIn) {
            checkIns.remove(object: checkIn)
        }

        func onCheckInUpdate(checkIn: CheckIn) {
            if let index = checkIns.firstIndex(of: checkIn) {
                checkIns[index] = checkIn
            }
        }
        
        func loadAndDismissSplashScreen(splashScreenState: SplashScreenState, dismissSplashScreen: @escaping () -> Void) {
            let (from, to) = getPagination(page: page, size: pageSize)
            
            Task {
                do {
                    await MainActor.run {
                        self.isLoading = true
                    }
                    
                    let checkIns = try await repository.checkIn.getActivityFeed(from: from, to: to)
                    
                    await MainActor.run {
                        self.checkIns.append(contentsOf: checkIns)
                        self.page += 1
                        
                        if splashScreenState != .finished {
                            dismissSplashScreen()
                        } else {
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }

        func fetchActivityFeedItems() {
            let (from, to) = getPagination(page: page, size: pageSize)
            Task {
                await MainActor.run {
                    self.isLoading = true
                }

                do {
                    let checkIns = try await repository.checkIn.getActivityFeed(from: from, to: to)

                    await MainActor.run {
                        self.checkIns.append(contentsOf: checkIns)
                        self.page += 1
                        self.isLoading = false
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}
