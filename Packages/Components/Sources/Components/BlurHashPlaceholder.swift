import Extensions
import Models
import SwiftUI

@MainActor
public struct BlurHashPlaceholder: View {
    @State private var image: UIImage?

    let blurHash: BlurHash?
    let height: Double

    public init(blurHash: BlurHash? = nil, height: Double) {
        self.blurHash = blurHash
        self.height = height
    }

    nonisolated func getBlurHashImage(blurHash: BlurHash) async -> UIImage? {
        let aspectRatio = blurHash.height / blurHash.width
        let width = 32.0
        let height = width * aspectRatio

        return UIImage(
            blurHash: blurHash.hash,
            size: CGSize(width: width, height: height)
        )
    }

    public var body: some View {
        HStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
                    .accessibility(hidden: true)
            } else {
                ProgressView()
            }
        }
        .task(id: blurHash) {
            guard let blurHash else { return }
            image = await getBlurHashImage(blurHash: blurHash)
        }
    }
}
