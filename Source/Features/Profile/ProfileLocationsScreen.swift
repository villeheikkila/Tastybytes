import EnvironmentModels
import Extensions
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileLocationsScreen: View {
    private let logger = Logger(category: "ProfileLocationsScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
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
            if let selectedLocation {
                HStack {
                    Spacer()
                    RouterLink("location.open \(selectedLocation.name)", screen: .location(selectedLocation))
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        })
        .navigationTitle("profile.locations.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCheckInlocations()
        }
    }

    func loadCheckInlocations() async {
        switch await repository.location.getCheckInLocations(userId: profile.id) {
        case let .success(checkInLocations):
            withAnimation {
                self.checkInLocations = checkInLocations
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading check-in locations statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}
