import Models
internal import NukeUI
import SwiftUI

public struct RemoteImage<Content: View, LoadingContent: View>: View {
    let url: URL?
    let content: (_: Image) -> Content
    let progress: () -> LoadingContent

    public init(url: URL?, @ViewBuilder content: @escaping (_: Image) -> Content, @ViewBuilder progress: @escaping () -> LoadingContent = { EmptyView() }) {
        self.url = url
        self.content = content
        self.progress = progress
    }

    public var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                content(image)
            } else {
                progress()
            }
        }
    }
}

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
            } else if let blurHash {
                BlurHashPlaceholder(blurHash: blurHash, height: height)
            } else {
                ProgressView()
                    .frame(height: height)
            }
        }
    }
}
