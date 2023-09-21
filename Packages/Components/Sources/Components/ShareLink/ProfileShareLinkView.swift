import Models
import SwiftUI

public struct ProfileShareLinkView: View {
    let profile: Profile

    public init(profile: Profile) {
        self.profile = profile
    }

    private var title: String {
        profile.preferredName
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url, preview: SharePreview(title))
    }
}
