import SwiftUI

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

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "AuthenticationScreen")
    let client: Client
    @Published var scene: Scene
    @Published var isLoading = false
    @Published var email = ""
    @Published var username = ""
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
      username = ""
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
            .warning("Error occured when trying to \(self.scene.rawValue): \(primaryActionError.localizedDescription)")
          onFailure(primaryActionError.localizedDescription)
        }

        self.isLoading = false
      }
    }
  }
}
