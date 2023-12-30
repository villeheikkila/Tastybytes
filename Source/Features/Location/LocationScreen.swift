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
    private let logger = Logger(category: "LocationScreen")
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var scrollToTop: Int = 0
    @State private var summary: Summary?
    @State private var showDeleteLocationConfirmation = false
    @State private var alertError: AlertError?
    @State private var isSuccess = false

    let location: Location

    var body: some View {
        CheckInList(
            id: "LocationScreen",
            fetcher: .location(location),
            scrollToTop: $scrollToTop,
            onRefresh: getSummary,
            header: {
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
                }
                Section {
                    SummaryView(summary: summary)
                }.padding(.horizontal).padding(.vertical, 4)
            }
        )
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sensoryFeedback(.success, trigger: isSuccess)
        .confirmationDialog(
            "Are you sure you want to delete the location, the location information for check-ins with this location will be permanently lost",
            isPresented: $showDeleteLocationConfirmation,
            titleVisibility: .visible,
            presenting: location
        ) { presenting in
            ProgressButton(
                "Delete \(presenting.name)",
                role: .destructive,
                action: { await deleteLocation(presenting) }
            )
        }
        .alertError($alertError)
        .task {
            await getSummary()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
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
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                LocationShareLinkView(location: location)
                Divider()

                if profileEnvironmentModel.hasRole(.admin) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canMergeLocations) {
                            RouterLink(sheet: .mergeLocationSheet(location: location), label: {
                                Label("Merge to...", systemImage: "doc.on.doc")
                            })
                        }
                        if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                            Button(
                                "Delete",
                                systemImage: "trash.fill",
                                role: .destructive,
                                action: { showDeleteLocationConfirmation.toggle() }
                            )
                        }
                    } label: {
                        Label("Admin", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("Options menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    func getSummary() async {
        switch await repository.location.getSummaryById(id: location.id) {
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

    @MainActor
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
