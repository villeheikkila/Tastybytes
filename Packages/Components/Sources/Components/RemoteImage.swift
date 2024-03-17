import Models
import NukeUI
import SwiftUI

@MainActor
public struct RemoteImage<Content: View>: View {
    let url: URL?
    let content: (LazyImageState) -> Content

    public init(url: URL?, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        self.url = url
        self.content = content
    }

    public var body: some View {
        LazyImage(url: url, content: content)
    }
}

@MainActor
public struct RemoteImageBlurHash<Content: View>: View {
    public typealias ImageBuilder = (Image) -> Content
    let url: URL?
    let blurHash: BlurHash?
    let height: Double
    let content: ImageBuilder

    public init(url: URL?, blurHash: BlurHash?, height: Double, @ViewBuilder content: @escaping ImageBuilder) {
        self.url = url
        self.blurHash = blurHash
        self.content = content
        self.height = height
    }

    public var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                content(image)
            } else {
                BlurHashPlaceholder(blurHash: blurHash, height: height)
            }
        }
    }
}
