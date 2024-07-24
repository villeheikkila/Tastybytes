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
    @State private var state: ScreenState = .loading
    @State private var checkInLocations = [Location.Saved]()
    @State private var selectedLocation: Location.Saved?

    let profile: Profile.Saved

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
                    RouterLink("location.open \(selectedLocation.name)", open: .screen(.location(selectedLocation)))
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

    private func loadCheckInlocations() async {
        do {
            let checkInLocations = try await repository.location.getCheckInLocations(userId: profile.id)
            withAnimation {
                self.checkInLocations = checkInLocations
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading check-in locations statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}
