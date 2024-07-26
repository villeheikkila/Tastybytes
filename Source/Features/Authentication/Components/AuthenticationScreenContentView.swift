import SwiftUI

struct AuthenticationScreenContentView: View {
    @Environment(Router.self) private var router
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
                SignInWithAppleView()
                    .frame(height: 52)
                PrivacyPolicyLinkView()
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
