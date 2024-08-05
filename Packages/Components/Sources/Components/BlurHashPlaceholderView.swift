internal import BlurHashViews
import SwiftUI

public struct BlurHashPlaceholderView: View {
    let blurHash: String

    public init(blurHash: String) {
        self.blurHash = blurHash
    }

    public var body: some View {
        MeshGradient(fromBlurHash: blurHash)
    }
}
