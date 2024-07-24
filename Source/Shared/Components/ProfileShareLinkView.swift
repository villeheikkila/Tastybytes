import EnvironmentModels
import Models
import SwiftUI

public struct ProfileShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let profile: Profile.Saved

    private var link: URL {
        NavigatablePath.profile(id: profile.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: String {
        profile.preferredName
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("profile.shareLink.subject \(profile.preferredName)"), message: Text(title))
    }
}
