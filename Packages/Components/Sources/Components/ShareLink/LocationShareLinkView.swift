import Models
import SwiftUI

public struct LocationShareLinkView: View {
    let location: Location

    public init(location: Location) {
        self.location = location
    }

    private var title: String {
        location.name
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.location(id: location.id).url, preview: SharePreview(title))
    }
}
