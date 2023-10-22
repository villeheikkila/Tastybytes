import Components
import EnvironmentModels
import Extensions
import OSLog
import Repositories
import SwiftUI

struct EmailPasswordAuthenticationView: View {
    private let logger = Logger(category: "EmailPasswordAuthenticationView")
    @Environment(\.repository) private var repository
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var scene: AuthenticationScene.Scene = .signIn
    @State private var isLoading = false
    @State private var email = ""
    @State private var username = ""
    @State private var isValidNewPassword = false
    @State private var alertError: AlertError?
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
        .alertError($alertError)
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
                    await MainActor.run {
                        dismiss()
                    }
                case let .failure(error):
                    alertError = .init(title: error.localizedDescription)
                    logger
                        .error(
                            "Error occured when trying to sign in. Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                        )
                }
            case .signUp:
                switch await repository.auth.signUp(username: username, email: email, password: password) {
                case .success:
                    await MainActor.run {
                        dismiss()
                    }
                    feedbackEnvironmentModel.toggle(.success("Confirmation email has been sent!"))
                    onSignUp()
                case let .failure(error):
                    alertError = .init(title: error.localizedDescription)
                    logger.error("Error occured when trying to sign up. Error: \(error) (\(#file):\(#line))")
                }
            case .resetPassword:
                switch await repository.auth.updatePassword(newPassword: password) {
                case .success:
                    await MainActor.run {
                        dismiss()
                    }
                    feedbackEnvironmentModel.toggle(.success("Confirmation email has been sent!"))
                    onSignUp()
                case let .failure(error):
                    alertError = .init(title: error.localizedDescription)
                    logger.error("Error occured when trying to reset password. Error: \(error) (\(#file):\(#line))")
                }
            case .forgotPassword:
                switch await repository.auth.sendPasswordResetEmail(email: email) {
                case .success:
                    await MainActor.run {
                        dismiss()
                    }
                    feedbackEnvironmentModel.toggle(.success("Password reset email sent!"))
                case let .failure(error):
                    alertError = .init(title: error.localizedDescription)
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

extension EmailPasswordAuthenticationView {
    enum Field {
        case username
        case email
        case password
        case resetPassword
    }
}
