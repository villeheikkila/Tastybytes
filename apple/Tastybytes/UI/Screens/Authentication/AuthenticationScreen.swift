import os
import SwiftUI

struct AuthenticationScreen: View {
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

  private let logger = getLogger(category: "AuthenticationScreen")
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
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

  let client: Client

  init(_ client: Client, scene: Scene) {
    self.client = client
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
          mode: scene == .resetPassword ? .newPassword : .password
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
      Button(action: { primaryActionTapped(onSuccess: { message in
        toastManager.toggle(.success(message))
      }, onFailure: { message in
        toastManager.toggle(.error(message))
      }) }, label: {
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

  func primaryActionTapped(
    onSuccess: @escaping (_ message: String) -> Void,
    onFailure: @escaping (_ message: String) -> Void
  ) {
    Task {
      isLoading = true
      var primaryActionSuccessMessage: String?
      var primaryActionError: Error?

      switch scene {
      case .signIn:
        switch await client.auth.signIn(email: email, password: password) {
        case .success:
          break
        case let .failure(error):
          primaryActionError = error
        }
      case .signUp:
        switch await client.auth.signUp(username: username, email: email, password: password) {
        case .success:
          primaryActionSuccessMessage = "Confirmation email has been sent!"
          onSignUp()
        case let .failure(error):
          primaryActionError = error
        }
      case .resetPassword:
        switch await client.auth.updatePassword(newPassword: password) {
        case .success:
          primaryActionSuccessMessage = "Confirmation email has been sent!"
          onSignUp()
        case let .failure(error):
          primaryActionError = error
        }
      case .forgotPassword:
        switch await client.auth.sendPasswordResetEmail(email: email) {
        case .success:
          primaryActionSuccessMessage = "Password reset email sent!"
        case let .failure(error):
          primaryActionError = error
        }
      case .magicLink:
        switch await client.auth.sendMagicLink(email: email) {
        case .success:
          primaryActionSuccessMessage = "Magic link sent!"
        case let .failure(error):
          primaryActionError = error
        }
      case .accountDeleted:
        setScene(.signIn)
      }

      if let primaryActionSuccessMessage {
        onSuccess(primaryActionSuccessMessage)
      } else if let primaryActionError {
        logger
          .warning("Error occured when trying to \(scene.rawValue): \(primaryActionError.localizedDescription)")
        onFailure(primaryActionError.localizedDescription)
      }

      isLoading = false
    }
  }
}
