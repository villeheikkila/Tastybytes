import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

enum ProfileCheckInListFilter: Sendable, Hashable, Codable {
    case dateRange(ClosedRange<Date>)
    case location(Location)

    var navigationTitle: String {
        switch self {
        case let .dateRange(dateRange):
            dateRange.title
        case let .location(location):
            location.name
        }
    }

    func fetcher(repository: Repository, profile: Profile) -> CheckInListLoader.Fetcher {
        switch self {
        case let .dateRange(dateRange):
            { from, to, _ in
                await repository.checkIn.getByProfileId(id: profile.id, queryType: .dateRange(from, to, dateRange))
            }
        case let .location(location):
            { from, to, _ in
                await repository.checkIn.getByProfileId(id: profile.id, queryType: .location(from, to, location))
            }
        }
    }

    @ViewBuilder var header: some View {
        if case let .location(location) = self {
            LocationScreenMap(location: location)
        }
    }

    @MainActor @ToolbarContentBuilder var toolbar: some ToolbarContent {
        if case let .location(location) = self {
            LocationToolbarItem(location: location)
            ToolbarItem(placement: .primaryAction) {
                RouterLink("location.open", systemImage: "mappin.and.ellipse", screen: .location(location))
            }
        }
    }
}

@MainActor
struct ProfileCheckInsList: View {
    @Environment(Repository.self) private var repository
    let profile: Profile
    let filter: ProfileCheckInListFilter

    var body: some View {
        ProfileCheckInsListInnerView(repository: repository, profile: profile, filter: filter)
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
    let filter: ProfileCheckInListFilter

    init(repository: Repository, profile: Profile, filter: ProfileCheckInListFilter) {
        self.profile = profile
        self.filter = filter
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: filter.fetcher(repository: repository, profile: profile), id: "ProfileCheckIns"))
    }

    var body: some View {
        List {
            filter.header
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
        .navigationTitle(filter.navigationTitle)
        .toolbar {
            filter.toolbar
        }
        .alertError($checkInLoader.alertError)
        .task {
            if screenState == .initial {
                await checkInLoader.loadData()
                screenState = .initialized
            }
        }
    }
}
