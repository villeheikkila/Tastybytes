import Components
import Logging
import Repositories
import SwiftUI

struct SignInWithGoogleView: View {
    private let logger = Logger(label: "SignInWithGoogleView")
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    var body: some View {
        SignInWithGoogleButtonView(onSignIn: onSignIn)
    }

    private func onSignIn(idToken: String, accessToken: String) async {
        do {
            try await repository.auth.signInWithGoogle(token: idToken, accessToken: accessToken)
        } catch {
            router.open(.alert(.init(title: .init(stringLiteral: error.localizedDescription))))
            logger.error("Error occured when trying to sign in with Google. Localized: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
            )
        }
    }
}
