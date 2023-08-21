import AuthenticationServices
import OSLog
import Supabase
import SwiftUI
@_spi(Experimental) import GoTrue
import Repositories

struct SignInWithAppleView: View {
    private let logger = Logger(category: "SignInWithAppleView")
    @Environment(\.colorScheme) var colorScheme
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            request.requestedScopes = [.email, .fullName]
        }, onCompletion: { result in Task {
            await handleAuthorizationResult(result)
        }})
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
    }

    private func handleAuthorizationResult(_ result: Result<ASAuthorization, Error>) async {
        if case let .success(asAuthorization) = result {
            guard let credential = asAuthorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken else { return }
            let token = String(decoding: tokenData, as: UTF8.self)

            if case let .failure(error) = await repository.auth.signInWithApple(token: token) {
                feedbackEnvironmentModel.toggle(.error(.custom(error.localizedDescription)))
                logger
                    .error(
                        "Error occured when trying to sign in with Apple . Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                    )
            }
        }
    }
}
