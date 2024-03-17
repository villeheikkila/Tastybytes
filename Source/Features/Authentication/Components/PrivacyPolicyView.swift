import EnvironmentModels
import SwiftUI

@MainActor
struct PrivacyPolicyView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var openUrlInWebView: WebViewLink?

    var body: some View {
        Text("authentication.welcomeAndPrivacyPolicy \(appEnvironmentModel.infoPlist.appName) [Privacy Policy](\(appEnvironmentModel.config.privacyPolicyUrl))")
            .font(.caption)
            .environment(\.openURL, OpenURLAction { url in
                openUrlInWebView = WebViewLink(title: "Privacy Policy", url: url)
                return .handled
            })
            .sheet(item: $openUrlInWebView) { link in
                NavigationStack {
                    WebView(url: link.url)
                        .ignoresSafeArea()
                        .navigationTitle(link.title)
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                CloseButton { openUrlInWebView = nil }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
    }
}

struct WebViewLink: Identifiable {
    var id: Int {
        "\(url)\(title)".hashValue
    }

    let title: String
    let url: URL
}
