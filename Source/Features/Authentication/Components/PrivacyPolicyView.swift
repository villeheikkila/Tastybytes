import EnvironmentModels
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Router.self) private var router

    var body: some View {
        Text("authentication.welcomeAndPrivacyPolicy \(appEnvironmentModel.infoPlist.appName) [Privacy Policy](\(appEnvironmentModel.config.privacyPolicyUrl))")
            .font(.caption)
            .environment(\.openURL, OpenURLAction { url in
                router.open(.sheet(.webView(link: .init(title: "Privacy Policy", url: url))))
                return .handled
            })
    }
}

struct WebViewLink: Identifiable {
    var id: Int {
        "\(url)\(title)".hashValue
    }

    let title: String
    let url: URL
}
