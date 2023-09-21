import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthenticationScreen: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(\.repository) private var repository
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var showAlternativeSignInMethods = false
    @State var authenticationScene: AuthenticationScene?

    var privacyPolicyString: String =
        "Visit [Privacy Policy](\(Config.privacyPolicyUrl)) to learn how your personal data is processed."

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        VStack(alignment: .center, spacing: 20) {
            Spacing(height: 30)
            projectLogo
            Spacer()
            instructionSection
            signInMethods
        }
        .padding(40)
        .frame(maxWidth: 500)
        .sheet(item: $authenticationScene) { authenticationScene in
            NavigationStack {
                AuthenticationModalView(authenticationScene: authenticationScene)
            }
            .presentationDetents([.height(authenticationScene.height)])
            .presentationBackground(.thinMaterial)
            .interactiveDismissDisabled(true)
        }
        .task {
            await splashScreenEnvironmentModel.dismiss()
        }
        .toast(isPresenting: $feedbackEnvironmentModel.show) {
            feedbackEnvironmentModel.toast
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

    @ViewBuilder
    private var instructionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Please choose how you want to sign up or sign in.")
            Text(.init(privacyPolicyString)).font(.caption)
        }
    }

    @ViewBuilder
    private var signInMethods: some View {
        VStack {
            SignInWithAppleView()
                .frame(height: 52)
            SignInButton(type: .magicLink, action: {
                authenticationScene = .magicLink
            })
            SignInButton(type: .password, action: {
                authenticationScene = .emailPassword(.signIn)
            })
        }
    }
}

struct AuthenticationModalView: View {
    @Environment(\.dismiss) private var dismiss
    let authenticationScene: AuthenticationScene

    var body: some View {
        authenticationScene.modal
            .padding([.leading, .trailing], 16)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Text(authenticationScene.title)
                        .font(.headline)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    CloseButtonView {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

enum AuthenticationScene: Identifiable {
    enum Scene: String {
        case signIn, signUp, resetPassword, forgotPassword

        var primaryLabel: String {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            case .resetPassword: "Reset Password"
            case .forgotPassword: "Send Reset Password Instructions"
            }
        }
    }

    var id: String {
        switch self {
        case .emailPassword:
            "email_password"
        case .magicLink:
            "magic_link"
        }
    }

    var title: String {
        switch self {
        case let .emailPassword(scene):
            switch scene {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            case .resetPassword, .forgotPassword: "Reset Password"
            }
        case .magicLink:
            "Magic Link"
        }
    }

    case emailPassword(Scene), magicLink

    var height: Double {
        switch self {
        case .emailPassword:
            400
        case .magicLink:
            200
        }
    }

    @ViewBuilder
    var modal: some View {
        switch self {
        case .emailPassword:
            EmailPasswordAuthenticationView()
        case .magicLink:
            MagicLinkAuthenticationView()
        }
    }
}
