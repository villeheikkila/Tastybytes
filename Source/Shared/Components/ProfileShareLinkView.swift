import EnvironmentModels
import Models
import SwiftUI

@MainActor
public struct ProfileShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let profile: Profile

    public init(profile: Profile) {
        self.profile = profile
    }

    private var link: URL {
        NavigatablePath.profile(id: profile.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: String {
        profile.preferredName
    }

    public var body: some View {
        ShareLink("Share", item: link, preview: SharePreview(title))
    }
}
