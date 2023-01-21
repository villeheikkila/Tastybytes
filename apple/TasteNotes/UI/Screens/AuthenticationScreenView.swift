import SwiftUI

struct AuthenticationScreenView: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
  @FocusState private var focusedField: Field?
  @State var mode: Mode = .signIn
  @State var isLoading = false
  @State var email = ""
  @State var password = ""

  var body: some View { VStack {
    VStack(spacing: 20) {
      Spacer()
      projectLogo
      Spacer()
      emailTextField
      if mode == .signIn || mode == .signUp {
        passwordTextField
      }
      actions
    }
    .padding(40)
    Spacer()
  }
  .task {
    splashScreenManager.dismiss()
  }
  }

  var projectLogo: some View {
    VStack(alignment: .center, spacing: 12) {
      AppLogoView()
      AppNameView()
    }
    .onTapGesture {
      self.focusedField = nil
    }
  }

  var emailTextField: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "envelope")
        TextField("Email address", text: $email)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .focused($focusedField, equals: .email)
      .padding()
      .padding(5)
      .background(Color(.systemGray6))
      .cornerRadius(12)
      .padding(.vertical, 5)
    }
  }

  var passwordTextField: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "key")
        SecureField("Password", text: $password)
          .textContentType(.password)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .focused($focusedField, equals: .password)
      .padding()
      .padding(5)
      .background(Color(.systemGray6))
      .cornerRadius(12)
      .padding(.vertical, 5)
    }
  }

  var actions: some View {
    VStack(spacing: 12) {
      Button(action: primaryActionTapped) {
        HStack(spacing: 8) {
          if isLoading {
            if #available(iOS 14.0, *) {
              ProgressView()
            } else {
              Text("Submitting...").bold()
            }
          }
          Text(primaryButtonText).bold()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 6, style: .continuous)
        )
      }
      .disabled(isLoading)

      if mode == .forgotPassword {
        HStack {
          Button("Go back to sign in") {
            withAnimation { mode = .signIn }
          }
          Spacer()
        }
      }

      if mode == .signIn {
        Button("Sign in with magic link") {
          withAnimation { mode = .magicLink }
        }
      }

      if mode == .signIn || mode == .signUp {
        Button(
          mode == .signIn
            ? "Don't have an account? Sign up"
            : "Do you have an account? Sign in"
        ) {
          withAnimation { mode = mode == .signIn ? .signUp : .signIn }
        }
      }

      if mode == .signIn {
        Button("Forgot your password?") {
          withAnimation { mode = .forgotPassword }
        }
      }

      if mode == .magicLink {
        Button("Sign in with password") {
          withAnimation { mode = .signIn }
        }
      }
    }
  }

  var primaryButtonText: String {
    switch mode {
    case .signIn: return "Sign in"
    case .signUp: return "Sign up"
    case .magicLink: return "Send magic link"
    case .forgotPassword: return "Send reset password instructions"
    }
  }

  func onSignUp() {
    DispatchQueue.main.async {
      mode = .signIn
      email = ""
      password = ""
      toastManager.toggle(.success("Confirmation email has been sent!"))
    }
  }

  func primaryActionTapped() {
    Task {
      self.isLoading.toggle()

      switch mode {
      case .signIn:
        switch await repository.auth.signIn(email: email, password: password) {
        case .success:
          break
        case let .failure(error):
          toastManager.toggle(.error(error.localizedDescription))
        }
      case .signUp:
        switch await repository.auth.signUp(email: email, password: password) {
        case .success:
          onSignUp()
        case let .failure(error):
          toastManager.toggle(.error(error.localizedDescription))
        }

      case .forgotPassword:
        switch await repository.auth.sendPasswordResetEmail(email: email) {
        case .success:
          toastManager.toggle(.success("Password reset email sent!"))
        case let .failure(error):
          toastManager.toggle(.error(error.localizedDescription))
        }

      case .magicLink:
        switch await repository.auth.sendMagicLink(email: email) {
        case .success:
          toastManager.toggle(.success("Magic link sent!"))
        case .failure:
          toastManager.toggle(.error("Invalid email"))
        }
      }

      self.isLoading.toggle()
    }
  }
}

extension AuthenticationScreenView {
  enum Mode {
    case signIn, signUp, magicLink, forgotPassword
  }

  enum Field {
    case email
    case password
  }
}
