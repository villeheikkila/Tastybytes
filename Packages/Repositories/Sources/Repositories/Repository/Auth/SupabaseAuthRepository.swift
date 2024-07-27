import Foundation
import Models
internal import Supabase

struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient

    func getUser() async throws -> Profile.Account {
        let response = try await client.auth.session.user
        return .init(id: .init(rawValue: response.id), email: response.email)
    }

    func logOut() async throws {
        try await client
            .auth
            .signOut()
    }

    func signInFromUrl(url: URL) async throws {
        try await client
            .auth
            .session(from: url)
    }

    func signInWithApple(token: String, nonce: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: token,
                nonce: nonce
            )
        )
    }

    func signInWithGoogle(token: String, accessToken: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .google,
                idToken: token,
                accessToken: accessToken
            )
        )
    }

    func sendMagicLink(email: String) async throws {
        try await client
            .auth
            .signInWithOTP(email: email, shouldCreateUser: true)
    }

    func signUp(username: String, email: String, password: String) async throws {
        try await client
            .auth
            .signUp(email: email, password: password, data: ["p_username": AnyJSON.string(username)])
    }

    func signIn(email: String, password: String) async throws {
        try await client
            .auth
            .signIn(email: email, password: password)
    }

    func sendEmailVerification(email: String) async throws {
        try await client
            .auth
            .update(user: UserAttributes(email: email))
    }

    func authStateListener() async -> AsyncStream<AuthState> {
        client.auth.authStateChanges.compactMap { event, session in
            switch event {
            case .initialSession: session != nil ? AuthState.authenticated : .unauthenticated
            case .signedIn: AuthState.authenticated
            case .signedOut: AuthState.unauthenticated
            case .passwordRecovery, .tokenRefreshed, .userUpdated, .userDeleted, .mfaChallengeVerified:
                nil
            }
        }
        .eraseToStream()
    }

    func refreshSession() async throws {
        try await client.auth.refreshSession()
    }
}

extension AsyncSequence {
    func eraseToStream() -> AsyncStream<Element> {
        AsyncStream(self)
    }
}
