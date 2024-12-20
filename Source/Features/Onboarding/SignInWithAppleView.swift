import AuthenticationServices
import CryptoKit
import Extensions
import Logging
import Repositories
import SwiftUI

struct SignInWithAppleView: View {
    private let logger = Logger(label: "SignInWithAppleView")
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var nonce: String?

    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            let nonce = randomString()
            self.nonce = nonce
            request.nonce = sha256(nonce)
            request.requestedScopes = [.email]
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
            guard let nonce else { return }
            do {
                try await repository.auth.signInWithApple(token: token, nonce: nonce)
            } catch {
                router.open(.alert(.init(title: .init(stringLiteral: error.localizedDescription))))
                logger.error("Error occured when trying to sign in with Apple. Localized: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
            }
        }
    }

    private nonisolated func randomString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private nonisolated func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
