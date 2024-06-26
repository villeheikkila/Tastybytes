import Components
import Models
import SwiftUI

struct ZoomableRemoteImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var location: CGPoint?
    let imageUrl: URL
    let blurHash: BlurHash?

    private let minScaleFactor = 0.8

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale != 1.0 else { return }
                location = value.location
            }
    }

    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scaleFactor in
                guard scaleFactor > minScaleFactor else { return }
                scale = scaleFactor.magnitude
            }
    }

    var body: some View {
        GeometryReader { geometry in
            RemoteImage(url: imageUrl) { state in
                let height = geometry.size.height * 0.8
                let width = geometry.size.width * 0.8
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(8)
                        .scaleEffect(scale)
                        .position(location ?? .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
                        .simultaneousGesture(zoomGesture)
                        .simultaneousGesture(dragGesture)
                        .frame(width: width, height: height)
                        .onTapGesture(count: 2) {
                            scale = 1
                            location = .init(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                } else if let blurHash {
                    BlurHashPlaceholder(blurHash: blurHash, height: height, width: width)
                } else {
                    ProgressView()
                }
            }
        }
    }
}
