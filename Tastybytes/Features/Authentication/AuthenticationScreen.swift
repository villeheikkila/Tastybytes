import Components
import EnvironmentModels
import Extensions
import LegacyUIKit
import Models
import OSLog
import Repositories
import SwiftUI

private let starsCount = 8

struct AuthenticationScreen: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(\.repository) private var repository
    @State private var openUrlInWebView: WebViewLink?

    var privacyPolicyString: String =
        "Welcome to Tastybytes! Please log in or create an account to continue. Your privacy is important to us; learn how we handle your data in our [Privacy Policy](\(Config.privacyPolicyUrl))"

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Spacer()
            Spacer()
            logo
            Spacer()
            Spacer()
            Spacer()
            actions
            Spacer()
        }
        .background(
            AppGradient(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
            alignment: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $openUrlInWebView) { link in
            NavigationStack {
                WebView(url: link.url)
                    .ignoresSafeArea()
                    .navigationTitle(link.title)
                    .toolbar {
                        ToolbarItemGroup(placement: .cancellationAction) {
                            CloseButtonView { openUrlInWebView = nil }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .dismissSplashScreen()
    }

    private var logo: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Spacer()
                AppLogoView(appIcon: .ramune)
                Spacer()
            }
            .background(
                SparklesView()
            )
            Text(Config.appName)
                .font(Font.custom("Comfortaa-Bold", size: 38))
                .bold()
        }
    }

    private var actions: some View {
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
    }
}

struct WebViewLink: Identifiable {
    var id: Int {
        "\(url)\(title)".hashValue
    }

    let title: String
    let url: URL
}
