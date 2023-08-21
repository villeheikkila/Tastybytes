import EnvironmentModels
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "ProfileLocationsScreen")

struct ProfileLocationsScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var checkInLocations = [Location]()
    @State private var selectedLocation: Location?

    let profile: Profile

    var body: some View {
        Map(initialPosition: MapCameraPosition
            .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384),
                          distance: 5000)),
            selection: $selectedLocation)
        {
            UserAnnotation()
            ForEach(checkInLocations) { location in
                if let coordinate = location.location?.coordinate {
                    Marker(location.name, coordinate: coordinate)
                        .tag(location)
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .safeAreaInset(edge: .bottom, content: {
            Group {
                if let selectedLocation {
                    HStack {
                        Spacer()
                        RouterLink("Open \(selectedLocation.name)", screen: .location(selectedLocation))
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                } else {
                    // TODO: Remove this
                    // This is only here to avoid a glitch where tab bar is not shown in full
                    HStack {
                        Spacer()
                    }
                    .padding(1)
                }
            }
            .background(.ultraThinMaterial)
        })
        .navigationTitle("Check-in Locations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task {
            await loadCheckInlocations()
        }
    }

    func loadCheckInlocations() async {
        switch await repository.location.getCheckInLocations(userId: profile.id) {
        case let .success(checkInLocations):
            await MainActor.run {
                withAnimation {
                    self.checkInLocations = checkInLocations
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed loading check-in locations statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}
