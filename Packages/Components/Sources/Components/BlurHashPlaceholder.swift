import Extensions
import Models
import SwiftUI
import BlurHashViews

@MainActor
public struct BlurHashPlaceholder: View {
    @State private var image: UIImage?

    let blurHash: BlurHash
    let height: CGFloat
    let width: CGFloat?

    public init(blurHash: BlurHash, height: CGFloat, width: CGFloat? = nil) {
        self.blurHash = blurHash
        self.height = height
        self.width = width
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
        MeshGradient(fromBlurHash: blurHash.hash)
    }
}

@MainActor
public struct LegacyBlurHashPlaceholder: View {
    @State private var image: UIImage?

    let blurHash: BlurHash?
    let height: CGFloat
    let width: CGFloat?

    public init(blurHash: BlurHash? = nil, height: CGFloat, width: CGFloat? = nil) {
        self.blurHash = blurHash
        self.height = height
        self.width = width
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
                    .frame(width: width, height: height)
                    .clipped()
                    .accessibility(hidden: true)
            } else {
                ProgressView()
                    .frame(width: width, height: height)
            }
        }
        .task(id: blurHash) {
            guard let blurHash else { return }
            image = await getBlurHashImage(blurHash: blurHash)
        }
    }
}
