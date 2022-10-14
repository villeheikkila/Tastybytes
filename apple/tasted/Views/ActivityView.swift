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
        @Published var checkIns = [CheckInResponse]()
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

            let query = API.supabase.database
                .rpc(fn: "fnc__get_activity_feed")
                .select(columns: "id, rating, review, created_at, profiles (id, username, avatar_url), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, avatar_url))")
                .range(from: from, to: to)

            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                let checkIns = try await query.execute().decoded(to: [CheckInResponse].self)

                DispatchQueue.main.async {
                    self.checkIns.append(contentsOf: checkIns)
                    self.page += 1
                    self.isLoading = false
                }
            }
        }
    }
}
