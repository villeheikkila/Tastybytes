import MapKit
import Models
import SwiftUI

struct LocationEntityView: View {
    let location: Location

    var body: some View {
        VStack {
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
                .frame(height: 150)
                .listRowSeparator(.hidden)
            }
            RouterLink(open: .screen(.location(location))) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(location.name)
                        if let title = location.title {
                            Text(title)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .contentShape(.rect)
            }
        }
    }
}
