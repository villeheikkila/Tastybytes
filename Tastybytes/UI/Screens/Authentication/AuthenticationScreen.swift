import Components
import EnvironmentModels
import Extensions
import LegacyUIKit
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthenticationScreen: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(\.repository) private var repository
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @State private var openUrlInWebView: WebViewLink?

    var privacyPolicyString: String =
        "Welcome to Tastybytes! Please log in or create an account to continue. Your privacy is important to us; learn how we handle your data in our [Privacy Policy](\(Config.privacyPolicyUrl))"

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacing(height: 30)
            projectLogo
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                SignInWithAppleView()
                    .frame(height: 52)
                Text(.init(privacyPolicyString))
                    .font(.caption)
                    .environment(\.openURL, OpenURLAction { url in
                        openUrlInWebView = WebViewLink(title: "Privacy Policy", url: url)
                        return .handled
                    })
            }
            .padding(40)
            .frame(maxWidth: 500)
            .sheet(item: $openUrlInWebView) { link in
                NavigationStack {
                    WebView(url: link.url)
                        .ignoresSafeArea()
                        .navigationTitle(link.title)
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                CloseButtonView { openUrlInWebView = nil }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .task {
                await splashScreenEnvironmentModel.dismiss()
            }
        }
    }

    private var projectLogo: some View {
        VStack(alignment: .center, spacing: 20) {
            AppLogoView()
            Text(Config.appName)
                .font(Font.custom("Comfortaa-Bold", size: 32))
                .bold()
            Spacing(height: 12)
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
