import Charts
import Components

import Extensions
import Models
import Logging
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
    private let logger = Logger(label: "ProfileCheckInsListInnerView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @State private var state: ScreenState = .loading
    @State private var checkIns = [CheckIn.Joined]()
    @State private var isLoading = false

    let profile: Profile.Saved
    let filter: ProfileCheckInListFilter

    var body: some View {
        List {
            if case let .location(location) = filter {
                LocationScreenMap(location: location)
            }
            CheckInListContentView(checkIns: $checkIns, onLoadMore: loadCheckIns)
            CheckInListLoadingIndicatorView(isLoading: $isLoading)
        }
        .listStyle(.plain)
        .animation(.default, value: checkIns)
        .scrollIndicators(.hidden)
        .checkInLoadedFrom(.activity(profileModel.profile))
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
        isLoading = true
        let lastCheckInId = checkIns.last?.id
        do {
            let startTime = DispatchTime.now()
            let pageSize = appModel.rateControl.checkInPageSize
            let fetchedCheckIns = switch filter {
            case let .dateRange(dateRange):
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .dateRange(lastCheckInId, pageSize, dateRange))
            case let .location(location):
                try await repository.checkIn.getByProfileId(id: profile.id, queryType: .location(lastCheckInId, pageSize, location.id))
            }
            logger.info("Succesfully loaded check-ins after \(lastCheckInId?.rawValue.formatted() ?? "lastest"), page size: \(pageSize) in \(startTime.elapsedTime())ms")
            checkIns.append(contentsOf: fetchedCheckIns)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            if lastCheckInId == nil {
                state = .error(error)
            }
        }
        isLoading = false
    }
}
