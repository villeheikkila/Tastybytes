import Charts
import GoTrue
import SwiftUI

struct ProfileView: View {
    let profile: Profile
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        InfiniteScrollView(data: $viewModel.checkIns, isLoading: $viewModel.isLoading, loadMore: { viewModel.fetchMoreCheckIns(userId: profile.id) },
                           refresh: {
            viewModel.refresh(userId: profile.id)
        },
                           content: {
            CheckInCardView(checkIn: $0,
                            loadedFrom: .profile(profile),
                            onDelete: {checkIn in viewModel.onCheckInDelete(checkIn: checkIn)
            },
                            onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn)})
        },
                           header: {
            VStack(spacing: 20) {
                profileSummary
                ratingChart
                ratingSummary
                sheets
            }
        })
    }
    
    var profileSummary: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            
            VStack {
                Text("Check-ins")
                    .font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(viewModel.profileSummary?.totalCheckIns ?? 0))
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
            
            VStack(alignment: .center) {
                Text(profile.getPreferredName())
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .lineLimit(1)
                    .font(.system(size: 500))
                    .minimumScaleFactor(0.01)
                AvatarView(avatarUrl: profile.getAvatarURL(), size: 80, id: profile.id)
            }
            
            VStack {
                Text("Unique")
                    .font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(viewModel.profileSummary?.uniqueCheckIns ?? 0))
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
            
            Spacer()
        }
        .task {
            viewModel.getProfileData(userId: profile.id)
        }
    }
    
    var ratingChart: some View {
        Chart {
            LineMark(
                x: .value("Rating", "0"),
                y: .value("Value", viewModel.profileSummary?.rating0 ?? 0)
            )
            LineMark(
                x: .value("Rating", "0.5"),
                y: .value("Value", viewModel.profileSummary?.rating1 ?? 0)
            )
            LineMark(
                x: .value("Rating", "1"),
                y: .value("Value", viewModel.profileSummary?.rating2 ?? 0)
            )
            LineMark(
                x: .value("Rating", "1.5"),
                y: .value("Value", viewModel.profileSummary?.rating3 ?? 0)
            )
            LineMark(
                x: .value("Rating", "2"),
                y: .value("Value", viewModel.profileSummary?.rating4 ?? 0)
            )
            LineMark(
                x: .value("Rating", "2.5"),
                y: .value("Value", viewModel.profileSummary?.rating5 ?? 0)
            )
            LineMark(
                x: .value("Rating", "3"),
                y: .value("Value", viewModel.profileSummary?.rating6 ?? 0)
            )
            LineMark(
                x: .value("Rating", "3.5"),
                y: .value("Value", viewModel.profileSummary?.rating7 ?? 0)
            )
            LineMark(
                x: .value("Rating", "4"),
                y: .value("Value", viewModel.profileSummary?.rating8 ?? 0)
            )
            LineMark(
                x: .value("Rating", "4.5"),
                y: .value("Value", viewModel.profileSummary?.rating9 ?? 0)
            )
            LineMark(
                x: .value("Rating", "5"),
                y: .value("Value", viewModel.profileSummary?.rating10 ?? 0)
            )
        }
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 100)
        .padding([.leading, .trailing], 10)
    }
    
    var ratingSummary: some View {
        HStack {
            VStack {
                Text("Unrated")
                    .font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(viewModel.profileSummary?.unrated ?? 0))
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
            VStack {
                Text("Average").font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
                Text(String(viewModel.profileSummary?.getFormattedAverageRating() ?? ""))
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
        }
    }
    
    var sheets: some View {
        VStack {
            NavigationLink(value: Route.friends(profile)) {
                Text("Friends")
            }
        }
    }
}

extension ProfileView {
    @MainActor class ViewModel: ObservableObject {
        @Published var checkIns = [CheckIn]()
        @Published var profileSummary: ProfileSummary?
        @Published var isLoading = false
        let pageSize = 10
        var page = 0
        
        func refresh(userId: UUID) {
            page = 0
            checkIns = []
            fetchMoreCheckIns(userId: userId)
        }
        
        func onCheckInUpdate(checkIn: CheckIn) {
            if let index = checkIns.firstIndex(of: checkIn) {
                DispatchQueue.main.async {
                    self.checkIns[index] = checkIn
                }
            }
        }
        func onCheckInDelete(checkIn: CheckIn) {
            DispatchQueue.main.async {
                self.checkIns.removeAll(where: { $0.id == checkIn.id })
            }
        }
        
        func fetchMoreCheckIns(userId: UUID) {
            let (from, to) = getPagination(page: page, size: pageSize)
            
            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                
                let checkIns = try await repository.checkIn.getByProfileId(id: userId, from: from, to: to)
                
                DispatchQueue.main.async {
                    self.checkIns.append(contentsOf: checkIns)
                    self.page += 1
                    self.isLoading = false
                }
            }
        }
        
        func getProfileData(userId: UUID) {
            Task {
                do {
                    let summary = try await repository.checkIn.getSummaryByProfileId(id: userId)
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
