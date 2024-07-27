import Models
import SwiftUI

public struct ZoomableRemoteImageView: View {
    let imageUrl: URL
    let blurHash: BlurHash?

    public init(imageUrl: URL, blurHash: BlurHash?) {
        self.imageUrl = imageUrl
        self.blurHash = blurHash
    }

    public var body: some View {
        ZoomableScrollableView {
            RemoteImageView(url: imageUrl, content: { image in
                image
                    .resizable()
                    .clipShape(.rect(cornerRadius: 8))
                    .scaledToFit()
                    .padding(.horizontal, 8)
            }, progress: {
                ProgressView()
            })
        }
    }
}
