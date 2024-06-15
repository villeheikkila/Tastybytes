import MapKit
import Models
import SwiftUI

@MainActor
struct MapThumbnail: View {
    @State private var showFullSizedMap = false

    let location: Location
    let coordinate: CLLocationCoordinate2D
    let distance: Measurement<UnitLength>?

    var body: some View {
        Map(initialPosition: MapCameraPosition
            .camera(.init(centerCoordinate: coordinate, distance: 300)))
        {
            Marker(location.name, coordinate: coordinate)
        }
        .frame(width: 60, height: 60)
        .cornerRadius(4, corners: .allCorners)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            showFullSizedMap = true
        }
        .popover(isPresented: $showFullSizedMap) {
            MapPopOver(location: location, coordinate: coordinate, distance: distance)
        }
    }
}

@MainActor
struct MapPopOver: View {
    @Environment(\.dismiss) private var dismiss
    let location: Location
    let coordinate: CLLocationCoordinate2D
    let distance: Measurement<UnitLength>?

    var body: some View {
        Map(initialPosition: MapCameraPosition
            .camera(.init(centerCoordinate: coordinate, distance: 300)))
        {
            Marker(location.name, coordinate: coordinate)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                    if let title = location.title {
                        Text(title)
                            .foregroundColor(.secondary)
                    }
                    if let distance {
                        Text("location.distance \(distance, format: .measurement(width: .narrow))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                CloseButton {
                    dismiss()
                }
            }
            .padding()
            .background(.thinMaterial)
        }
    }
}
