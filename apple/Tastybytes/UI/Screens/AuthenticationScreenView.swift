import os
import SwiftUI

struct AuthenticationScreenView: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
  @StateObject private var viewModel: ViewModel
  @FocusState private var focusedField: Field?

  init(_ client: Client, scene: Scene) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, scene: scene))
  }

  var body: some View {
    VStack(spacing: 20) {
      projectLogo
      if !(viewModel.scene == .resetPassword || viewModel.scene == .accountDeleted) {
        EmailTextFieldView(email: $viewModel.email, focusedField: _focusedField)
      }
      if viewModel.scene == .signIn || viewModel.scene == .signUp || viewModel.scene == .resetPassword {
        PasswordTextFieldView(password: $viewModel.password, focusedField: _focusedField)
      }
      if viewModel.scene == .resetPassword {
        PasswordTextFieldView(password: $viewModel.passwordConfirmation, focusedField: _focusedField)
      }

      if viewModel.scene == .accountDeleted {
        accountDeletion
      }
      actions
    }
    .padding(40)
    .task {
      splashScreenManager.dismiss()
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
          Text("Account Deleted")
            .font(.system(size: 24))
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
    .onTapGesture {
      self.focusedField = nil
    }
  }

  private var actions: some View {
    VStack(spacing: 12) {
      Button(action: { viewModel.primaryActionTapped(onSuccess: {
        message in toastManager.toggle(.success(message))
      }, onFailure: {
        message in toastManager.toggle(.error(message))
      }) }) {
        HStack(spacing: 8) {
          if viewModel.isLoading {
            ProgressView()
          }
          Text(viewModel.scene.primaryLabel).bold()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 6, style: .continuous)
        )
      }
      .disabled(viewModel.isLoading || (viewModel.scene == .resetPassword && !viewModel.isValidNewPassword))

      if viewModel.scene == .forgotPassword {
        HStack {
          Button("Go back to sign in") {
            viewModel.setScene(.signIn)
          }
          Spacer()
        }
      }

      if viewModel.scene == .signIn || viewModel.scene == .signUp {
        Button(
          viewModel.scene == .signIn
            ? "Don't have an account? Sign up"
            : "Do you have an account? Sign in"
        ) {
          viewModel.setScene(viewModel.scene == .signIn ? .signUp : .signIn)
        }
      }

      if viewModel.scene == .signIn {
        Button("Sign in with magic link") {
          viewModel.setScene(.magicLink)
        }
      }

      if viewModel.scene == .signIn {
        Button("Forgot your password?") {
          viewModel.setScene(.forgotPassword)
        }
      }

      if viewModel.scene == .magicLink {
        Button("Sign in with password") {
          viewModel.setScene(.signIn)
        }
      }
    }
  }

  private struct PasswordTextFieldView: View {
    @Binding var password: String
    @FocusState var focusedField: Field?

    var body: some View {
      VStack(alignment: .leading) {
        HStack {
          Image(systemName: "key")
          SecureField("Password", text: $password)
            .textContentType(.password)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        .focused($focusedField, equals: .password)
        .modifier(AuthenticationInput())
      }
    }
  }

  private struct EmailTextFieldView: View {
    @Binding var email: String
    @FocusState var focusedField: Field?

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "envelope")
          TextField("Email address", text: $email)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        .modifier(AuthenticationInput())
        .focused($focusedField, equals: .email)
      }
    }
  }
}

struct AuthenticationInput: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding()
      .padding(5)
      .background(Color(.systemGray6))
      .cornerRadius(12)
      .padding(.vertical, 5)
  }
}

extension AuthenticationScreenView {
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

  enum Field {
    case email
    case password
    case resetPassword
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "AuthenticationScreenView")
    let client: Client
    @Published var scene: Scene
    @Published var isLoading = false
    @Published var email = ""
    @Published var isValidNewPassword = false
    @Published var password = "" {
      didSet {
        passwordCheck()
      }
    }

    @Published var passwordConfirmation = "" {
      didSet {
        passwordCheck()
      }
    }

    init(_ client: Client, scene: Scene) {
      self.scene = scene
      self.client = client
    }

    func setScene(_ scene: Scene) {
      withAnimation {
        self.scene = scene
      }
    }

    private func onSignUp() {
      scene = .signIn
      email = ""
      password = ""
    }

    private func passwordCheck() {
      isValidNewPassword = password == passwordConfirmation && password.count >= 8
    }

    func primaryActionTapped(
      onSuccess: @escaping (_ message: String) -> Void,
      onFailure: @escaping (_ message: String) -> Void
    ) {
      Task {
        self.isLoading.toggle()
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
          switch await client.auth.signUp(email: email, password: password) {
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
            .warning("Error occured when trying to \(self.scene.rawValue): \(primaryActionError.localizedDescription)")
          onFailure(primaryActionError.localizedDescription)
        }

        self.isLoading = false
      }
    }
  }
}
