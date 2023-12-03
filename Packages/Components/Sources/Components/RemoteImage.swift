import NukeUI
import SwiftUI

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
