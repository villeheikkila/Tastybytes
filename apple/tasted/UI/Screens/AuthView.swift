import GoTrue
import Supabase
import SwiftUI

public struct AuthView<AuthenticatedContent: View, LoadingContent: View>: View {

  private let supabaseClient: SupabaseClient
  private let magicLinkEnabled: Bool
  private let loadingContent: () -> LoadingContent
  private let authenticatedContent: (Session) -> AuthenticatedContent

  @State private var authEvent: AuthChangeEvent?

  public init(
    supabaseClient: SupabaseClient,
    magicLinkEnabled: Bool = true,
    @ViewBuilder loadingContent: @escaping () -> LoadingContent,
    @ViewBuilder authenticatedContent: @escaping (Session) -> AuthenticatedContent
  ) {
    self.supabaseClient = supabaseClient
    self.magicLinkEnabled = magicLinkEnabled
    self.loadingContent = loadingContent
    self.authenticatedContent = authenticatedContent
  }

  public var body: some View {
    Group {
      switch (authEvent, supabaseClient.auth.session) {
      case (.signedIn, let session?):
        authenticatedContent(session)
      case (nil, _):
        loadingContent()
      default:
        SignInOrSignUpView(
          supabaseClient: supabaseClient,
          magicLinkEnabled: magicLinkEnabled
        )
      }
    }
    .onOpenURL { url in
      Task { _ = try await supabaseClient.auth.session(from: url) }
    }
    .task {
      for await authEventChange in supabaseClient.auth.authEventChange.values {
        withAnimation {
          self.authEvent = authEventChange
        }
      }
    }
  }
}

struct SignInOrSignUpView: View {
  let supabaseClient: SupabaseClient

  enum ResultStatus {
    case idle
    case loading
    case result(Result<Void, Error>)

    var isLoading: Bool {
      if case .loading = self {
        return true
      }
      return false
    }
  }

  enum Mode {
    case signIn, signUp, magicLink, forgotPassword
  }

  let magicLinkEnabled: Bool

  @State var email = ""
  @State var password = ""

  @State var mode: Mode = .signIn
  @State var status = ResultStatus.idle

  var body: some View {
    VStack(spacing: 20) {
      emailTextField

      if mode == .signIn || mode == .signUp {
        passwordTextField
      }

      VStack(spacing: 12) {
        if mode == .signIn {
          HStack {
            Spacer()
            Button("Forgot your password?") {
              withAnimation { mode = .forgotPassword }
            }
          }
        }

        Button(action: primaryActionTapped) {
          HStack(spacing: 8) {
            if status.isLoading {
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
        .disabled(status.isLoading)

        if mode == .forgotPassword {
          HStack {
            Button("Go back to sign in") {
              withAnimation { mode = .signIn }
            }

            Spacer()
          }
        }

        if magicLinkEnabled, mode == .signIn {
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

        if mode == .magicLink {
          Button("Sign in with password") {
            withAnimation { mode = .signIn }
          }
        }
      }
      if case let .result(.failure(error)) = status {
        Text(error.localizedDescription).foregroundColor(.red).multilineTextAlignment(.center)
      }
    }
    .padding(20)
  }

  var emailTextField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Email address").font(.subheadline)
      HStack {
        Image(systemName: "envelope")
        TextField("", text: $email)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .stroke()
      )
    }
  }

  var passwordTextField: some View {
    VStack(alignment: .leading) {
      Text("Password").font(.subheadline)
      HStack {
        Image(systemName: "key")
        SecureField("", text: $password)
          .textContentType(.password)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .stroke()
      )
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

  private func primaryActionTapped() {
    Task {
      status = .loading

      do {
        switch mode {
        case .signIn:
          _ = try await supabaseClient.auth.signIn(email: email, password: password)
        case .signUp:
          _ = try await supabaseClient.auth.signUp(email: email, password: password)
        case .magicLink:
          try await supabaseClient.auth.signIn(email: email)
        case .forgotPassword:
          fatalError("Not supported")
        }
        status = .result(.success(()))
      } catch {
        NSLog(
          "Error on %@: %@",
          String(describing: mode),
          error.localizedDescription
        )

        withAnimation {
          status = .result(.failure(error))
        }
      }
    }
  }
}
