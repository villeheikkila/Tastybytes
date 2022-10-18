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
    @StateObject private var model = ActivityViewModel()
    @State var isLoading: Bool = true

    var body: some View {
        InfiniteScroll(data: $model.checkIns, isLoading: $model.isLoading, loadMore: {
            model.fetchActivityFeedItems()
        }, refresh: {
            model.refresh()
        }, content: {
            content in
            CheckInCardView(checkIn: content)
        })
    }
}

extension ActivityView {
    class ActivityViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var isLoading = false
        let pageSize = 5
        var page = 0

        struct ActivityFeedRequest: Encodable {
            let p_created_after: String

            init(createdAter: String) {
                p_created_after = createdAter
            }
        }

        func refresh() {
            page = 0
            checkIns = []
            fetchActivityFeedItems()
        }

        func fetchActivityFeedItems() {
            let (from, to) = getPagination(page: page, size: pageSize)
            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                do {
                    let checkIns = try await SupabaseCheckInRepository().loadCurrentUserActivityFeed(from: from, to: to)
                    
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

