import Models
import SwiftUI

struct ProfileShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let profile: Profile.Saved

    private var link: URL {
        NavigatablePath.profile(id: profile.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    private var title: String {
        profile.preferredName
    }

    var body: some View {
        ShareLink(item: link, subject: Text("profile.shareLink.subject \(profile.preferredName)"), message: Text(title))
    }
}
