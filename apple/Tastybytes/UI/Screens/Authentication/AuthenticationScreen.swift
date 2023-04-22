import os
import SwiftUI

struct AuthenticationScreen: View {
  private let logger = getLogger(category: "AuthenticationScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @FocusState private var focusedField: Field?
  @State private var scene: Scene
  @State private var isLoading = false
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

  init(scene: Scene) {
    _scene = State(wrappedValue: scene)
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
    VStack(spacing: scene == .signUp ? 4 : 20) {
      projectLogo
      if scene == .signUp {
        UsernameTextFieldView(username: $username)
          .focused($focusedField, equals: .username)
      }
      if [.signIn, .signUp, .resetPassword, .accountDeleted, .magicLink, .forgotPassword].contains(scene) {
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
        PasswordTextFieldView(password: $passwordConfirmation, mode: .newPassword)
          .focused($focusedField, equals: .resetPassword)
      }

      if scene == .accountDeleted {
        accountDeletion
      }
      actions
    }
    .padding(40)
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
          Image(systemName: "trash.circle")
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
    VStack(alignment: .center, spacing: 12) {
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

  private var actions: some View {
    VStack(spacing: 12) {
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
        Button("Sign in with magic link") {
          setScene(.magicLink)
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
          logger.error("Error occured when trying to \(scene.rawValue): \(error.localizedDescription)")
        }
      case .signUp:
        switch await repository.auth.signUp(username: username, email: email, password: password) {
        case .success:
          feedbackManager.toggle(.success("Confirmation email has been sent!"))
          onSignUp()
        case let .failure(error):
          feedbackManager.toggle(.error(.custom(error.localizedDescription)))
          logger.error("Error occured when trying to \(scene.rawValue): \(error.localizedDescription)")
        }
      case .resetPassword:
        switch await repository.auth.updatePassword(newPassword: password) {
        case .success:
          feedbackManager.toggle(.success("Confirmation email has been sent!"))
          onSignUp()
        case let .failure(error):
          feedbackManager.toggle(.error(.custom(error.localizedDescription)))
          logger.error("Error occured when trying to \(scene.rawValue): \(error.localizedDescription)")
        }
      case .forgotPassword:
        switch await repository.auth.sendPasswordResetEmail(email: email) {
        case .success:
          feedbackManager.toggle(.success("Password reset email sent!"))
        case let .failure(error):
          feedbackManager.toggle(.error(.custom(error.localizedDescription)))
          logger.error("Error occured when trying to \(scene.rawValue): \(error.localizedDescription)")
        }
      case .magicLink:
        switch await repository.auth.sendMagicLink(email: email) {
        case .success:
          feedbackManager.toggle(.success("Magic link sent!"))
        case let .failure(error):
          feedbackManager.toggle(.error(.custom(error.localizedDescription)))
          logger.error("Error occured when trying to \(scene.rawValue): \(error.localizedDescription)")
        }
      case .accountDeleted:
        setScene(.signIn)
      }

      isLoading = false
    }
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
      case .signIn: return "Sign in"
      case .signUp: return "Sign up!"
      case .magicLink: return "Send magic link"
      case .resetPassword: return "Reset password"
      case .forgotPassword: return "Send reset password instructions"
      case .accountDeleted: return "Go back to sign in page"
      }
    }
  }
}
