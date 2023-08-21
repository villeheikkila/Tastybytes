import Charts
import EnvironmentModels
import MapKit
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct LocationScreen: View {
    private let logger = Logger(category: "LocationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var scrollToTop: Int = 0
    @State private var summary: Summary?
    @State private var showDeleteLocationConfirmation = false

    let location: Location

    var body: some View {
        CheckInListView(
            fetcher: .location(location),
            scrollToTop: $scrollToTop,
            onRefresh: { await getSummary() },
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
                    .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                Section {
                    SummaryView(summary: summary)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        )
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
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
        .task {
            await getSummary()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                LocationShareLinkView(location: location)
                Divider()

                if profileEnvironmentModel.hasRole(.admin) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canMergeLocations) {
                            RouterLink(sheet: .mergeLocationSheet(location: location), label: {
                                Label("Merge to...", systemSymbol: .docOnDoc)
                            })
                        }
                        if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                            Button(
                                "Delete",
                                systemSymbol: .trashFill,
                                role: .destructive,
                                action: { showDeleteLocationConfirmation.toggle() }
                            )
                        }
                    } label: {
                        Label("Admin", systemSymbol: .gear)
                            .labelStyle(.iconOnly)
                    }
                }
            } label: {
                Label("Options menu", systemSymbol: .ellipsis)
                    .labelStyle(.iconOnly)
            }
        }
    }

    func getSummary() async {
        switch await repository.location.getSummaryById(id: location.id) {
        case let .success(summary):
            await MainActor.run {
                withAnimation {
                    self.summary = summary
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to get summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLocation(_ location: Location) async {
        switch await repository.location.delete(id: location.id) {
        case .success:
            router.reset()
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}
