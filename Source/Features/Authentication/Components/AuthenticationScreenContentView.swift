import Components
import SwiftUI

struct AuthenticationScreenContentView: View {
    @Environment(Router.self) private var router
    @Environment(AppModel.self) private var appModel
    @AppStorage(.profileDeleted) private var profileDeleted = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                logo
                    .padding(.top, max(0, (geometry.size.height - 200) / 2))
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onChange(of: profileDeleted, initial: true) {
            if profileDeleted {
                router.open(.sheet(.profileDeleteConfirmation))
                profileDeleted = false
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                Text("authentication.welcome \(appModel.infoPlist.appName)")
                Group {
                    SignInWithAppleView()
                    SignInWithGoogleView()
                }
                .frame(height: 52)
                Text("[Privacy Policy](privacyPolicy) [Terms of Service](termsOfService)")
                    .font(.caption)
                    .environment(\.openURL, OpenURLAction { url in
                        print("URLZ \(url.path())")
                        if url == URL(string: "privacyPolicy") {
                            router.open(.sheet(.privacyPolicy))
                        } else if url == URL(string: "termsOfService") {
                            router.open(.sheet(.termsOfService))
                        }
                        return .handled
                    })
            }
            .padding(40)
            .frame(maxWidth: 500)
        }
    }

    private var logo: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Spacer()
                AppLogoView(appIcon: .ramune)
                    .frame(width: 120, height: 120)
                Spacer()
            }
            .overlay(
                SparklesView()
            )
            AppNameView(size: 38)
        }
    }
}
