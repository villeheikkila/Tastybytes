import SwiftUI

struct SimpleCheckIn {
    let name: String
    let subBrandName: String
    let brandName: String
    let companyName: String
    let rating: Double
    let creator: String
}

struct ActivityView: View {
    let profile: Profile
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, loadMore: {
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

extension ActivityView {
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
            DispatchQueue.main.async {
                self.checkIns.remove(object: checkIn)
            }
        }
        
        func onCheckInUpdate(checkIn: CheckIn) {
            if let index = checkIns.firstIndex(of: checkIn) {
                DispatchQueue.main.async {
                    self.checkIns[index] = checkIn
                }
            }
        }
        
        func fetchActivityFeedItems() {
            let (from, to) = getPagination(page: page, size: pageSize)
            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                
                do {
                    let checkIns = try await repository.checkIn.getActivityFeed(from: from, to: to)
                    
                    DispatchQueue.main.async {
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
