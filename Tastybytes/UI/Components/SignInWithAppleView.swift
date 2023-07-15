import AuthenticationServices
import OSLog
import Supabase
import SwiftUI
@_spi(Experimental) import GoTrue

struct SignInWithAppleView: View {
    private let logger = Logger(category: "SignInWithAppleView")
    @Environment(\.colorScheme) var colorScheme
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager

    var body: some View {
        SignInWithAppleButton(onRequest: { request in
            request.requestedScopes = [.email, .fullName]
        }, onCompletion: { result in Task {
            await handleAuthorizationResult(result)
        }})
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(width: 200, height: 50)
    }

    private func handleAuthorizationResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case let .success(asAuthorization):
            guard let credential = asAuthorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken else { return }
            let token = String(decoding: tokenData, as: UTF8.self)

            if case let .failure(error) = await repository.auth.signInWithApple(token: token) {
                feedbackManager.toggle(.error(.custom(error.localizedDescription)))
                logger
                    .error(
                        "Error occured when trying to sign in with Apple . Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                    )
            }
        case let .failure(error):
            feedbackManager.toggle(.error(.custom(error.localizedDescription)))
            logger
                .error(
                    "Error while requesting sign in with Apple. Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
