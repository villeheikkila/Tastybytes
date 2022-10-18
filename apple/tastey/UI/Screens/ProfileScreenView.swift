import Charts
import GoTrue
import SwiftUI

struct ProfileView: View {
    @StateObject private var model = ProfileViewModel()
    let userId: UUID

    var body: some View {
        InfiniteScroll(data: $model.checkIns, isLoading: $model.isLoading, loadMore: { model.fetchMoreCheckIns(userId: userId) },
                       refresh: {
                           model.refresh(userId: userId)
                       },
                       content: {
                           CheckInCardView(checkIn: $0)
                       },
                       header: {
                           VStack(spacing: 20) {
                               profileSummary
                               ratingChart
                               ratingSummary
                           }
                       })
    }

    var profileSummary: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack {
                Text("Check-ins").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(model.profileSummary?.totalCheckIns ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
            }

            AvatarView(avatarUrl: model.profile?.getAvatarURL(), size: 80, id: userId)

            VStack {
                Text("Unique").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(model.profileSummary?.uniqueCheckIns ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
            }
        }
        .task {
            model.getProfileData(userId: userId)
        }
    }

    var ratingChart: some View {
        Chart {
            LineMark(
                x: .value("Rating", "0"),
                y: .value("Value", model.profileSummary?.rating0 ?? 0)
            )
            LineMark(
                x: .value("Rating", "0.5"),
                y: .value("Value", model.profileSummary?.rating1 ?? 0)
            )
            LineMark(
                x: .value("Rating", "1"),
                y: .value("Value", model.profileSummary?.rating2 ?? 0)
            )
            LineMark(
                x: .value("Rating", "1.5"),
                y: .value("Value", model.profileSummary?.rating3 ?? 0)
            )
            LineMark(
                x: .value("Rating", "2"),
                y: .value("Value", model.profileSummary?.rating4 ?? 0)
            )
            LineMark(
                x: .value("Rating", "2.5"),
                y: .value("Value", model.profileSummary?.rating5 ?? 0)
            )
            LineMark(
                x: .value("Rating", "3"),
                y: .value("Value", model.profileSummary?.rating6 ?? 0)
            )
            LineMark(
                x: .value("Rating", "3.5"),
                y: .value("Value", model.profileSummary?.rating7 ?? 0)
            )
            LineMark(
                x: .value("Rating", "4"),
                y: .value("Value", model.profileSummary?.rating8 ?? 0)
            )
            LineMark(
                x: .value("Rating", "4.5"),
                y: .value("Value", model.profileSummary?.rating9 ?? 0)
            )
            LineMark(
                x: .value("Rating", "5"),
                y: .value("Value", model.profileSummary?.rating10 ?? 0)
            )
        }
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 100)
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }

    var ratingSummary: some View {
        HStack {
            VStack {
                Text("Unrated").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(model.profileSummary?.unrated ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
            }
            VStack {
                Text("Average").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(model.profileSummary?.averageRating ?? 0)).font(.system(size: 16, weight: .bold, design: .default))
            }
        }
    }
}

extension ProfileView {
    @MainActor class ProfileViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var profile: Profile?
        @Published var profileSummary: ProfileSummary?
        @Published var isLoading = false
        let pageSize = 10
        var page = 0

        func refresh(userId: UUID) {
            page = 0
            checkIns = []
            fetchMoreCheckIns(userId: userId)
        }

        func fetchMoreCheckIns(userId: UUID) {
            let (from, to) = getPagination(page: page, size: pageSize)
            
            print("page ", page)
            print("from ", from)
            print("to ", to)

            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                let checkIns = try await SupabaseCheckInRepository().loadByProfileId(id: userId, from: from, to: to)

                DispatchQueue.main.async {
                    self.checkIns.append(contentsOf: checkIns)
                    self.page += 1
                    self.isLoading = false
                }
            }
        }

        func getProfileData(userId: UUID) {
            Task {
                let profile = try await SupabaseProfileRepository().loadProfileById(id: userId)
                DispatchQueue.main.async {
                    self.profile = profile
                }
            }

            Task {
                do {
                    let summary = try await SupabaseCheckInRepository().getSummaryByProfileId(id: userId)
                    DispatchQueue.main.async {
                        self.profileSummary = summary
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}
