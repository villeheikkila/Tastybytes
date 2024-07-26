import Charts
import Components

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
    private let logger = Logger(category: "ProfileCheckInsListInnerView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @State private var state: ScreenState = .loading
    @State private var checkIns = [CheckIn.Joined]()
    @State private var isLoading = false
    @State private var page = 0

    let profile: Profile.Saved
    let filter: ProfileCheckInListFilter

    var body: some View {
        List {
            if case let .location(location) = filter {
                LocationScreenMap(location: location)
            }
            CheckInListContentView(checkIns: $checkIns, onLoadMore: {
                await loadCheckIns()
            })
            CheckInListLoadingIndicatorView(isLoading: $isLoading)
        }
        .listStyle(.plain)
        .animation(.default, value: checkIns)
        .scrollIndicators(.hidden)
        .checkInCardLoadedFrom(.activity(profileModel.profile))
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadCheckIns()
            }
        }
        .navigationTitle(filter.navigationTitle)
        .toolbar {
            filter.toolbar
        }
        .initialTask {
            await loadCheckIns()
        }
    }

    func loadCheckIns() async {
        guard !isLoading else { return }
        let (from, to) = getPagination(page: page, size: appModel.rateControl.checkInPageSize)
        isLoading = true
        do {
            let fetchedCheckIns = switch filter {
            case let .dateRange(dateRange):
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .dateRange(from, to, dateRange))
            case let .location(location):
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .location(from, to, location))
            }
            logger.info("Succesfully loaded check-ins from \(from) to \(to)")
            checkIns.append(contentsOf: fetchedCheckIns)
            state = .populated
            page += 1
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            if page == 0 {
                state = .error(error)
            }
        }
        isLoading = false
    }
}
