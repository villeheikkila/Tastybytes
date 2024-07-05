import Charts
import Components
import EnvironmentModels
import Extensions
import MapKit
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct LocationScreen: View {
    @Environment(Repository.self) private var repository
    let location: Location

    var body: some View {
        LocationInnerScreen(repository: repository, location: location)
    }
}

struct LocationInnerScreen: View {
    private let logger = Logger(category: "LocationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var summary: Summary?
    @State private var location: Location
    @State private var checkInLoader: CheckInListLoader

    init(repository: Repository, location: Location) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, segment in
            await repository.checkIn.getByLocation(locationId: location.id, segment: segment, from: from, to: to)
        }, id: "LocationScreen"))
        _location = State(initialValue: location)
    }

    var body: some View {
        List {
            if state == .populated {
                LocationScreenHeader(location: location, summary: summary)
                CheckInListSegmentPicker(showCheckInsFrom: $checkInLoader.showCheckInsFrom)
                CheckInListContent(checkIns: $checkInLoader.checkIns, loadedFrom: .location(location), onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: {
                    checkInLoader.onLoadMore()
                })
                CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await getLocationData(isRefresh: true)
        }
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await getLocationData(isRefresh: true)
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await getLocationData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        LocationToolbarItem(location: location)
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                LocationShareLinkView(location: location)
                Divider()
                AdminRouterLink(open: .sheet(.locationAdmin(location: location, onEdit: { location in
                    withAnimation {
                        self.location = location
                    }
                }, onDelete: { _ in
                    router.removeLast()
                })))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    func getLocationData(isRefresh: Bool = false) async {
        async let loadInitialCheckInsPromise: Void = checkInLoader.loadData(isRefresh: isRefresh)
        async let summaryPromise = repository.location.getSummaryById(id: location.id)

        let (_, summaryResult) = await (loadInitialCheckInsPromise, summaryPromise)

        switch summaryResult {
        case let .success(summary):
            withAnimation {
                self.summary = summary
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error([error])
            }
            logger.error("Failed to get summary. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct LocationScreenHeader: View {
    let location: Location
    let summary: Summary?

    var body: some View {
        if let coordinate = location.location?.coordinate {
            Map(initialPosition: MapCameraPosition
                .camera(.init(centerCoordinate: coordinate, distance: 200)))
            {
                Marker(location.name, coordinate: coordinate)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 200)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
        }
        SummaryView(summary: summary)
    }
}

struct LocationScreenMap: View {
    let location: Location

    var body: some View {
        if let coordinate = location.location?.coordinate {
            Map(initialPosition: MapCameraPosition
                .camera(.init(centerCoordinate: coordinate, distance: 200)))
            {
                Marker(location.name, coordinate: coordinate)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 200)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
        }
    }
}

struct LocationToolbarItem: ToolbarContent {
    var location: Location

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(location.name)
                    .font(.headline)
                if let title = location.title {
                    Text(title)
                        .font(.caption)
                }
            }
        }
    }
}
