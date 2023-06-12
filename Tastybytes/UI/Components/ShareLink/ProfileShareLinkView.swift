import SwiftUI

struct ProfileShareLinkView: View {
    let profile: Profile

    private var title: String {
        profile.preferredName
    }

    var body: some View {
        ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url, preview: SharePreview(title))
    }
}
