import MapKit
import Models
import SwiftUI

@MainActor
struct MapThumbnail: View {
    @State private var showFullSizedMap = false
    @State private var image: UIImage?

    let location: Location
    let coordinate: CLLocationCoordinate2D
    let distance: Measurement<UnitLength>?

    var body: some View {
        HStack {
            if let image {
                Image(uiImage: image)
            } else {
                ProgressView()
            }
        }
        .frame(width: 60, height: 60)
        .task {
            image = try? await generateSnapshot(width: 60, height: 60)
        }
        .cornerRadius(4, corners: .allCorners)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            showFullSizedMap = true
        }
        .popover(isPresented: $showFullSizedMap) {
            MapPopOver(location: location, coordinate: coordinate, distance: distance)
        }
    }

    nonisolated func generateSnapshot(width: CGFloat, height: CGFloat) async throws -> UIImage {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )

        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true

        let snapshotter = MKMapSnapshotter(options: mapOptions)

        return try await withCheckedThrowingContinuation { continuation in
            snapshotter.start { snapshotOrNil, errorOrNil in
                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                    return
                }
                if let snapshot = snapshotOrNil {
                    continuation.resume(returning: snapshot.image)
                }
            }
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
