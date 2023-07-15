import OSLog
import SwiftUI

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

        var title: String {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            case .resetPassword, .forgotPassword: "Reset Password"
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

    case emailPassword(Scene), magicLink

    var height: Double {
        switch self {
        case .emailPassword:
            400
        case .magicLink:
            200
        }
    }
}

struct AuthenticationScreen: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(Repository.self) private var repository
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var isLoading = false
    @State private var showAlternativeSignInMethods = false
    @State var authenticationScene: AuthenticationScene?
    @State private var email = ""
    @State private var username = ""
    @State private var isValidNewPassword = false
    @State private var password = "" {
        didSet {
            passwordCheck()
        }
    }

    @State private var passwordConfirmation = "" {
        didSet {
            passwordCheck()
        }
    }

    private func passwordCheck() {
        isValidNewPassword = password == passwordConfirmation && password.count >= 8
    }

    var body: some View {
        @Bindable var feedbackManager = feedbackManager
        VStack(spacing: 20) {
            projectLogo
            SignInWithAppleView()
            Button("Alternative Sign-in Methods") {
                showAlternativeSignInMethods.toggle()
            }
        }
        .padding(40)
        .frame(maxWidth: 500)
        .sheet(item: $authenticationScene) { modal in
            NavigationStack {
                switch modal {
                case .emailPassword:
                    EmailPasswordAuthenticationModal()
                case .magicLink:
                    MagicLinkAuthenticationView()
                }
            }
            .presentationDetents([.height(modal.height)])
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

    func signUpWithMagicLink() async {
        isLoading = true
        switch await repository.auth.sendMagicLink(email: email) {
        case .success:
            feedbackManager.toggle(.success("Magic link sent!"))
        case let .failure(error):
            feedbackManager.toggle(.error(.custom(error.localizedDescription)))
            logger
                .error(
                    "Error occured when trying to log in with magic link. Error: \(error) (\(#file):\(#line))"
                )
        }
        isLoading = false
    }
}

extension EmailPasswordAuthenticationModal {
    enum Field {
        case username
        case email
        case password
        case resetPassword
    }
}

struct EmailPasswordAuthenticationModal: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(Repository.self) private var repository
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @FocusState private var focusedField: Field?
    @State private var scene: AuthenticationScene.Scene = .signIn
    @State private var isLoading = false
    @State private var showAlternativeSignInMethods = false
    @State private var signInModalMode: AuthenticationScene?
    @State private var email = ""
    @State private var username = ""
    @State private var isValidNewPassword = false
    @State private var password = "" {
        didSet {
            passwordCheck()
        }
    }

    @State private var passwordConfirmation = "" {
        didSet {
            passwordCheck()
        }
    }

    func setScene(_ scene: AuthenticationScene.Scene) {
        withAnimation {
            self.scene = scene
        }
    }

    private func onSignUp() {
        scene = .signIn
        username = ""
        email = ""
        password = ""
    }

    private func passwordCheck() {
        isValidNewPassword = password == passwordConfirmation && password.count >= 8
    }

    var body: some View {
        ScrollView {
            if scene == .signUp {
                UsernameTextFieldView(username: $username)
                    .focused($focusedField, equals: .username)
            }
            if [.signIn, .signUp, .forgotPassword].contains(scene) {
                EmailTextFieldView(email: $email)
                    .focused($focusedField, equals: .email)
            }
            if [.signIn, .signUp, .resetPassword].contains(scene) {
                PasswordTextFieldView(
                    password: $password,
                    mode: scene == .signIn ? .password : .newPassword
                )
                .focused($focusedField, equals: .password)
            }
            if scene == .resetPassword {
                PasswordTextFieldView(password: $passwordConfirmation, mode: .confirmPassword)
                    .focused($focusedField, equals: .resetPassword)
            }
            actions
        }
        .padding([.leading, .trailing], 16)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Text(scene.primaryLabel)
                    .font(.headline)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    signInModalMode = nil
                }, label: {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 30,
                               height: 30)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold,
                                              design: .rounded))
                                .foregroundColor(.secondary)
                        )
                })
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Close"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        .onTapGesture {
            focusedField = nil
        }
    }

    private var primaryAction: some View {
        Button(action: { primaryActionTapped() }, label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                }
                Text(scene.primaryLabel).bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
        })
        .disabled(isLoading || (scene == .resetPassword && !isValidNewPassword))
    }

    private var actions: some View {
        VStack(spacing: 12) {
            primaryAction

            if scene == .forgotPassword {
                HStack {
                    Button("Go back to sign in", action: { setScene(.signIn) })
                    Spacer()
                }
            }

            if [.signIn, .signUp].contains(scene) {
                Button(
                    scene == .signIn
                        ? "Don't have an account? Sign up"
                        : "Do you have an account? Sign in"
                ) {
                    setScene(scene == .signIn ? .signUp : .signIn)
                }
            }

            if scene == .signIn {
                Button("Forgot your password?") {
                    setScene(.forgotPassword)
                }
            }
        }
    }

    func primaryActionTapped() {
        Task {
            isLoading = true

            switch scene {
            case .signIn:
                switch await repository.auth.signIn(email: email, password: password) {
                case .success:
                    break
                case let .failure(error):
                    feedbackManager.toggle(.error(.custom(error.localizedDescription)))
                    logger
                        .error(
                            "Error occured when trying to sign in. Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                        )
                }
            case .signUp:
                switch await repository.auth.signUp(username: username, email: email, password: password) {
                case .success:
                    feedbackManager.toggle(.success("Confirmation email has been sent!"))
                    onSignUp()
                case let .failure(error):
                    feedbackManager.toggle(.error(.custom(error.localizedDescription)))
                    logger.error("Error occured when trying to sign up. Error: \(error) (\(#file):\(#line))")
                }
            case .resetPassword:
                switch await repository.auth.updatePassword(newPassword: password) {
                case .success:
                    feedbackManager.toggle(.success("Confirmation email has been sent!"))
                    onSignUp()
                case let .failure(error):
                    feedbackManager.toggle(.error(.custom(error.localizedDescription)))
                    logger.error("Error occured when trying to reset password. Error: \(error) (\(#file):\(#line))")
                }
            case .forgotPassword:
                switch await repository.auth.sendPasswordResetEmail(email: email) {
                case .success:
                    feedbackManager.toggle(.success("Password reset email sent!"))
                case let .failure(error):
                    feedbackManager.toggle(.error(.custom(error.localizedDescription)))
                    logger
                        .error(
                            "Error occured when trying to send forgot password link. Error: \(error) (\(#file):\(#line))"
                        )
                }
            }

            isLoading = false
        }
    }
}

struct MagicLinkAuthenticationView: View {
    private let logger = Logger(category: "AuthenticationScreen")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var email = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            EmailTextFieldView(email: $email)
            ProgressButton(action: { await signUpWithMagicLink() }, actionOptions: Set(), label: {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                    }
                    Text("Send Magic Link").bold()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
            })
            .disabled(isLoading)
        }
        .padding([.leading, .trailing], 16)
        .navigationTitle("Magic Link")
        .navigationBarTitleDisplayMode(.inline)
    }

    func signUpWithMagicLink() async {
        isLoading = true
        switch await repository.auth.sendMagicLink(email: email) {
        case .success:
            feedbackManager.toggle(.success("Magic link sent!"))
        case let .failure(error):
            feedbackManager.toggle(.error(.custom(error.localizedDescription)))
            logger
                .error(
                    "Error occured when trying to log in with magic link. Error: \(error) (\(#file):\(#line))"
                )
        }
        isLoading = false
    }
}
