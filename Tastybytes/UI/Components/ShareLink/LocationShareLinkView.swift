import Model
import SwiftUI

struct LocationShareLinkView: View {
    let location: Location

    private var title: String {
        location.name
    }

    var body: some View {
        ShareLink("Share", item: NavigatablePath.location(id: location.id).url, preview: SharePreview(title))
    }
}
