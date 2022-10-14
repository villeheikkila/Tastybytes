import Charts
import GoTrue
import SwiftUI

struct ProfileView: View {
    @StateObject private var model = ProfileViewModel()
    let userId: UUID

    var body: some View {
        ScrollView {
            HStack(spacing: 30) {
                Spacer()

                VStack {
                    Text("Check-ins").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                    Text(String(model.profileSummary?.total_check_ins ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
                }
                Avatar(avatarUrl: model.profile?.avatar_url, size: 100, id: userId)

                VStack {
                    Text("Unique").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                    Text(String(model.profileSummary?.unique_check_ins ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
                }
                Spacer()

            }.padding(.leading, 20).padding(.trailing, 20)

            Chart {
                BarMark(
                    x: .value("Rating", "0"),
                    y: .value("Value", model.profileSummary?.rating_0 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "0.5"),
                    y: .value("Value", model.profileSummary?.rating_1 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "1"),
                    y: .value("Value", model.profileSummary?.rating_2 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "1.5"),
                    y: .value("Value", model.profileSummary?.rating_3 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "2"),
                    y: .value("Value", model.profileSummary?.rating_4 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "2.5"),
                    y: .value("Value", model.profileSummary?.rating_5 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "3"),
                    y: .value("Value", model.profileSummary?.rating_6 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "3.5"),
                    y: .value("Value", model.profileSummary?.rating_7 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "4"),
                    y: .value("Value", model.profileSummary?.rating_8 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "4.5"),
                    y: .value("Value", model.profileSummary?.rating_9 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "5"),
                    y: .value("Value", model.profileSummary?.rating_10 ?? 0)
                )
            }
            .chartLegend(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
            .padding(.leading, 10)
            .padding(.trailing, 10)

            HStack {
                VStack {
                    Text("Unrated").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                    Text(String(model.profileSummary?.unrated ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
                }
                VStack {
                    Text("Average").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                    Text(String(model.profileSummary?.average_rating ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
                }
            }
            
            InfiniteScroll(data: $model.checkIns, isLoading: $model.isLoading, loadMore: { model.fetchMoreCheckIns(userId: userId) },
                           refresh: {
                model.refreshCheckIns()
            },
                           content: {
                CheckInCardView(checkIn: $0)
            })
        }
    }
}

extension ProfileView {
    @MainActor class ProfileViewModel: ObservableObject {
        @Published var checkIns = [CheckInResponse]()
        @Published var profile: Profile?
        @Published var profileSummary: ProfileSummary?
        @Published var isLoading = false
        let pageSize = 1
        var page = 0

        func refreshCheckIns() {
            // TODO: Implement fetching of new items
        }

        func fetchMoreCheckIns(userId: UUID) {
            let (from, to) = getPagination(page: page, size: pageSize)
            
            if isLoading {
                return
            }

            let query = API.supabase.database
                .from("check_ins")
                .select(columns: "id, rating, review, created_at, profiles (id, username, avatar_url), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, avatar_url))")
                .eq(column: "created_by", value: userId.uuidString.lowercased())
                .order(column: "created_at")
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

        func getInitialData(userId: UUID) {
            let id = userId.uuidString.lowercased()

            let profileQuery = API.supabase.database
                .from("profiles")
                .select(columns: "*", count: .exact)
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()

            let profileSummaryQuery = API.supabase.database
                .rpc(fn: "fnc__get_profile_summary", params: GetProfileSummaryQuery(p_uid: id))
                .select()
                .limit(count: 1)
                .single()

            Task {
                let profile = try await profileQuery.execute().decoded(to: Profile.self)
                DispatchQueue.main.async {
                    self.profile = profile
                }
            }

            Task {
                let summary = try await profileSummaryQuery.execute().decoded(to: ProfileSummary.self)
                DispatchQueue.main.async {
                    self.profileSummary = summary
                }
            }
        }

        struct GetProfileSummaryQuery: Encodable {
            let p_uid: String
        }
    }
}
