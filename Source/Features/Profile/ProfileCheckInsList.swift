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
    case location(Location.Saved)

    var navigationTitle: String {
        switch self {
        case let .dateRange(dateRange):
            dateRange.title
        case let .location(location):
            location.name
        }
    }

    func fetcher(repository: Repository, profile: Profile.Saved) -> CheckInListLoader.Fetcher {
        switch self {
        case let .dateRange(dateRange):
            { from, to, _ in
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .dateRange(from, to, dateRange))
            }
        case let .location(location):
            { from, to, _ in
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .location(from, to, location))
            }
        }
    }

    @ViewBuilder var header: some View {
        if case let .location(location) = self {
            LocationScreenMap(location: location)
        }
    }

    @MainActor
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        if case let .location(location) = self {
            LocationToolbarItem(location: location)
            ToolbarItem(placement: .primaryAction) {
                RouterLink("location.open", systemImage: "mappin.and.ellipse", open: .screen(.location(location.id)))
            }
        }
    }
}

struct ProfileCheckInsList: View {
    @Environment(Repository.self) private var repository
    let profile: Profile.Saved
    let filter: ProfileCheckInListFilter

    var body: some View {
        ProfileCheckInsListInnerView(repository: repository, profile: profile, filter: filter)
    }
}

struct ProfileCheckInsListInnerView: View {
    private let logger = Logger(category: "ProfileCheckInsListInnerView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var state: ScreenState = .loading

    let profile: Profile.Saved
    let filter: ProfileCheckInListFilter

    init(repository: Repository, profile: Profile.Saved, filter: ProfileCheckInListFilter) {
        self.profile = profile
        self.filter = filter
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: filter.fetcher(repository: repository, profile: profile), id: "ProfileCheckIns"))
    }

    var body: some View {
        List {
            filter.header
            CheckInListContentView(checkIns: $checkInLoader.checkIns, onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn,
                                   onLoadMore: checkInLoader.onLoadMore)
            CheckInListLoadingIndicatorView(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .refreshable {
            await checkInLoader.fetchFeedItems(reset: true, showCheckInsFrom: .you)
        }
        .checkInCardLoadedFrom(.activity(profileEnvironmentModel.profile))
        .overlay {
            if checkInLoader.errorContentUnavailable != nil {
                ContentUnavailableView {
                    Label("activity.error.failedToLoad", systemImage: "exclamationmark.triangle")
                } actions: {
                    AsyncButton("labels.reload") {
                        await checkInLoader.fetchFeedItems(reset: true, showCheckInsFrom: .you)
                    }
                }
            } else if state.isPopulated, checkInLoader.checkIns.isEmpty, !checkInLoader.isLoading {
                EmptyActivityFeedView()
            }
        }
        .navigationTitle(filter.navigationTitle)
        .toolbar {
            filter.toolbar
        }
        .onChange(of: checkInLoader.alertError) { _, alertError in
            if let alertError {
                router.open(.alert(alertError))
            }
        }
        .initialTask {
            await checkInLoader.loadData()
            state = .populated
        }
    }
}
