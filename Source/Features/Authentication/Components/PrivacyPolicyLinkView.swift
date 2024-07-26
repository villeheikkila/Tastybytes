
import SwiftUI

struct PrivacyPolicyLinkView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(Router.self) private var router

    var body: some View {
        Text("authentication.welcomeAndPrivacyPolicy \(appModel.infoPlist.appName) [Privacy Policy](\(appModel.config.privacyPolicyUrl))")
            .font(.caption)
            .environment(\.openURL, OpenURLAction { _ in
                router.open(.sheet(.privacyPolicy))
                return .handled
            })
    }
}
