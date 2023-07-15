import OSLog
import SwiftUI

enum AuthenticationModalMode: String, Identifiable {
    var id: String {
        rawValue
    }

    case emailPassword, magicLink

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
    @FocusState private var focusedField: Field?
    @State var scene: Scene
    @State private var isLoading = false
    @State private var showAlternativeSignInMethods = false
    @State private var signInModalMode: AuthenticationModalMode?
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

    func setScene(_ scene: Scene) {
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
        @Bindable var feedbackManager = feedbackManager
        VStack(spacing: scene == .signUp ? 4 : 20) {
            projectLogo
            if scene == .accountDeleted {
                accountDeletion
            }
            SignInWithAppleView()
            Button("Alternative Sign-in Methods") {
                showAlternativeSignInMethods.toggle()
            }
        }
        .padding(40)
        .frame(maxWidth: 500)
        .sheet(item: $signInModalMode) { modal in
            NavigationStack {
                switch modal {
                case .emailPassword:
                    ScrollView {
                        if scene == .signUp {
                            UsernameTextFieldView(username: $username)
                                .focused($focusedField, equals: .username)
                        }
                        if [.signIn, .signUp, .accountDeleted, .magicLink, .forgotPassword].contains(scene) {
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
                    .navigationTitle("Sign In")
                    .navigationBarTitleDisplayMode(.inline)
                case .magicLink:
                    VStack {
                        EmailTextFieldView(email: $email)
                            .focused($focusedField, equals: .email)
                        ProgressButton(action: { await signUpWithMagicLink() }, actionOptions: Set(), label: {
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
                        .disabled(isLoading)
                    }
                    .padding([.leading, .trailing], 16)
                    .navigationTitle("Magic Link")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .presentationDetents([.height(modal.height)])
            .presentationBackground(.thinMaterial)
        }
        .confirmationDialog("Alternative Sign-in Methods",
                            isPresented: $showAlternativeSignInMethods,
                            titleVisibility: .visible)
        {
            Button("Email & Password") {
                signInModalMode = .emailPassword
            }
            Button("Magic Link") {
                signInModalMode = .magicLink
            }
        }
        .task {
            await splashScreenManager.dismiss()
        }
        .toast(isPresenting: $feedbackManager.show) {
            feedbackManager.toast
        }
    }

    private var accountDeletion: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemSymbol: .trashCircle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .accessibility(hidden: true)
                    Text("Account Deleted")
                        .font(.title)
                }
                Spacer()
            }
            Spacer()
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

            if scene == .magicLink {
                Button("Sign in with password") {
                    setScene(.signIn)
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
            case .magicLink:
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
            case .accountDeleted:
                setScene(.signIn)
            }

            isLoading = false
        }
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

extension AuthenticationScreen {
    enum Field {
        case username
        case email
        case password
        case resetPassword
    }

    enum Scene: String {
        case signIn, signUp, magicLink, resetPassword, forgotPassword, accountDeleted

        var primaryLabel: String {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            case .magicLink: "Send Magic Link"
            case .resetPassword: "Reset Password"
            case .forgotPassword: "Send Reset Password Instructions"
            case .accountDeleted: "Go Back to Sign in Page"
            }
        }
    }
}
