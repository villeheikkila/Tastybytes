import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AuthenticationScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

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
            Text(appEnvironmentModel.infoPlist.appName)
                .font(.custom("Comfortaa-Bold", size: 38))
                .bold()
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SignInWithAppleView()
                .frame(height: 52)
            PrivacyPolicy()
        }
        .padding(40)
        .frame(maxWidth: 500)
    }
}

@MainActor
struct PrivacyPolicy: View {
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
