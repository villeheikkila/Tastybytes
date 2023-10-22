import AuthenticationServices
import EnvironmentModels
import Extensions
import OSLog
import Repositories
import SwiftUI

struct SignInWithAppleView: View {
    private let logger = Logger(category: "SignInWithAppleView")
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.repository) private var repository
    @State private var alertError: AlertError?

    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            request.requestedScopes = [.email, .fullName]
        }, onCompletion: { result in Task {
            await handleAuthorizationResult(result)
        }})
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .alertError($alertError)
    }

    private func handleAuthorizationResult(_ result: Result<ASAuthorization, Error>) async {
        if case let .success(asAuthorization) = result {
            guard let credential = asAuthorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken else { return }
            let token = String(decoding: tokenData, as: UTF8.self)

            if case let .failure(error) = await repository.auth.signInWithApple(token: token) {
                alertError = AlertError(title: error.localizedDescription)
                logger
                    .error(
                        "Error occured when trying to sign in with Apple . Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                    )
            }
        }
    }
}
