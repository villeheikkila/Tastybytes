@preconcurrency import GoogleSignIn
import GoogleSignInSwift
import Logging
import SwiftUI
import UIKit

public struct SignInWithGoogleButtonView: View {
    public typealias OnSignIn = (_ idToken: String, _ accessToken: String) async -> Void

    private let logger = Logger(label: "SignInWithGoogleButtonView")
    @State private var signInTask: Task<Void, Never>?

    private let onSignIn: OnSignIn

    public init(onSignIn: @escaping OnSignIn) {
        self.onSignIn = onSignIn
    }

    public var body: some View {
        GoogleSignInButton(style: .wide, action: handleSignIn)
    }

    func handleSignIn() {
        signInTask = Task {
            let rootViewController = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last?.rootViewController ?? UIViewController()
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                guard let idToken = result.user.idToken?.tokenString else {
                    logger.error("No 'idToken' returned by GIDSignIn call.")
                    return
                }
                let accessToken = result.user.accessToken.tokenString

                await onSignIn(idToken, accessToken)
            } catch {
                logger.error("Failed to login-in with Google: \(error)")
            }
        }
    }
}
