import SwiftUI

@MainActor
struct AuthenticationScreenContent: View {
    var body: some View {
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

    private var logo: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Spacer()
                AppLogoView(appIcon: .ramune)
                Spacer()
            }
            #if !os(watchOS)
            .background(
                SparklesView()
            )
            #endif
            AppNameView(size: 38)
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SignInWithAppleView()
                .frame(height: 52)
            PrivacyPolicyView()
        }
        .padding(40)
        .frame(maxWidth: 500)
    }
}
