import AuthenticationServices
import CryptoKit
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
    @State private var nonce: String?

    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            let nonce = randomString()
            self.nonce = nonce
            request.nonce = sha256(nonce)
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

            if let nonce, case let .failure(error) = await repository.auth.signInWithApple(token: token, nonce: nonce) {
                alertError = AlertError(title: error.localizedDescription)
                logger.error(
                    "Error occured when trying to sign in with Apple. Localized: \(error.localizedDescription) Error: \(error) (\(#file):\(#line))"
                )
            }
        }
    }
}

private func randomString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
    }

    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
    }

    return String(nonce)
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}
