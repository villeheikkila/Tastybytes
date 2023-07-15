import OSLog
import SwiftUI

struct AuthenticationScreen: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(Repository.self) private var repository
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var showAlternativeSignInMethods = false
    @State var authenticationScene: AuthenticationScene?

    var body: some View {
        @Bindable var feedbackManager = feedbackManager
        VStack(spacing: 20) {
            projectLogo
            SignInWithAppleView()
            alternativeSignInMethods
        }
        .padding(40)
        .frame(maxWidth: 500)
        .task {
            await splashScreenManager.dismiss()
        }
        .toast(isPresenting: $feedbackManager.show) {
            feedbackManager.toast
        }
    }

    private var projectLogo: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            AppLogoView()
            AppNameView()
            Spacer()
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
    }

    private var alternativeSignInMethods: some View {
        Button("Alternative Sign-in Methods", action: {
            showAlternativeSignInMethods.toggle()
        })
        .sheet(item: $authenticationScene) { authenticationScene in
            NavigationStack {
                AuthenticationModalView(authenticationScene: authenticationScene)
            }
            .presentationDetents([.height(authenticationScene.height)])
            .presentationBackground(.thinMaterial)
            .interactiveDismissDisabled(true)
        }
        .confirmationDialog("Alternative Sign-in Methods",
                            isPresented: $showAlternativeSignInMethods,
                            titleVisibility: .visible)
        {
            Button("Email & Password") {
                authenticationScene = .emailPassword(.signIn)
            }
            Button("Magic Link") {
                authenticationScene = .magicLink
            }
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
