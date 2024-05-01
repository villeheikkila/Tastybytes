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

@MainActor
struct LocationScreen: View {
    @Environment(Repository.self) private var repository
    let location: Location

    var body: some View {
        LocationInnerScreen(repository: repository, location: location)
    }
}

@MainActor
struct LocationInnerScreen: View {
    private let logger = Logger(category: "LocationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var scrollToTop: Int = 0
    @State private var summary: Summary?
    @State private var showDeleteLocationConfirmation = false
    @State private var alertError: AlertError?
    @State private var isSuccess = false
    @State private var sheet: Sheet?

    @State private var checkInLoader: CheckInListLoader

    let location: Location

    init(repository: Repository, location: Location) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, segment in
            await repository.checkIn.getByLocation(locationId: location.id, segment: segment, from: from, to: to)
        }, id: "LocationScreen"))
        self.location = location
    }

    var body: some View {
        List {
            LocationScreenHeader(location: location, summary: summary)
                .sheets(item: $sheet)
            CheckInListSegmentPicker(showCheckInsFrom: $checkInLoader.showCheckInsFrom)
            CheckInListContent(checkIns: $checkInLoader.checkIns, alertError: $checkInLoader.alertError, loadedFrom: .location(location), onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: {
                checkInLoader.onLoadMore()
            })
            CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
        }
        .listStyle(.plain)
        .refreshable {
            await getLocationData(isRefresh: true)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sensoryFeedback(.success, trigger: isSuccess)
        .alertError($alertError)
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

                if profileEnvironmentModel.hasRole(.admin) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canMergeLocations) {
                            Button(action: { sheet = .mergeLocationSheet(location: location) }, label: {
                                Label("location.mergeTo.label", systemImage: "doc.on.doc")
                            })
                        }
                        if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                            Button(
                                "labels.delete",
                                systemImage: "trash.fill",
                                role: .destructive,
                                action: { showDeleteLocationConfirmation.toggle() }
                            )
                        }
                    } label: {
                        Label("labels.admin", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
            .confirmationDialog(
                "location.delete.confirmation.description",
                isPresented: $showDeleteLocationConfirmation,
                titleVisibility: .visible,
                presenting: location
            ) { presenting in
                ProgressButton(
                    "location.delete.confirmation.label \(presenting.name)",
                    role: .destructive,
                    action: { await deleteLocation(presenting) }
                )
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
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to get summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLocation(_ location: Location) async {
        switch await repository.location.delete(id: location.id) {
        case .success:
            router.reset()
            isSuccess = true
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
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
        Section {
            SummaryView(summary: summary)
        }
    }
}

@MainActor
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
