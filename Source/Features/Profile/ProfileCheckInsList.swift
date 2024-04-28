import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct ProfileCheckInsList: View {
    @Environment(Repository.self) private var repository
    let profile: Profile
    let dateRange: ClosedRange<Date>

    var body: some View {
        ProfileCheckInsListInnerView(repository: repository, profile: profile, dateRange: dateRange)
    }
}

@MainActor
struct ProfileCheckInsListInnerView: View {
    enum ScreenState {
        case initial, initialized
    }

    private let logger = Logger(category: "ProfileCheckInsListInnerView")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var screenState: ScreenState = .initial

    let profile: Profile
    let dateRange: ClosedRange<Date>

    init(repository: Repository, profile: Profile, dateRange: ClosedRange<Date>) {
        self.profile = profile
        self.dateRange = dateRange
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { _, _, _ in
            await repository.checkIn.getByProfileId(id: profile.id, queryType: .dateRange(dateRange))
        }, id: "ProfileCheckIns"))
    }

    var body: some View {
        List {
            CheckInListContent(checkIns: $checkInLoader.checkIns, alertError: $checkInLoader.alertError, loadedFrom: .activity(profileEnvironmentModel.profile), onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn,
                               onLoadMore: checkInLoader.onLoadMore)
            CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .refreshable {
            await checkInLoader.fetchFeedItems(reset: true)
        }
        .overlay {
            if checkInLoader.errorContentUnavailable != nil {
                ContentUnavailableView {
                    Label("activity.error.failedToLoad", systemImage: "exclamationmark.triangle")
                } actions: {
                    ProgressButton("labels.reload") {
                        await checkInLoader.fetchFeedItems(reset: true)
                    }
                }
            } else if screenState == .initialized, checkInLoader.checkIns.isEmpty, !checkInLoader.isLoading {
                EmptyActivityFeedView()
            }
        }
        .navigationTitle(dateRange.title)
        .alertError($checkInLoader.alertError)
        .task {
            if screenState == .initial {
                await checkInLoader.loadData()
                screenState = .initialized
            }
        }
    }
}
