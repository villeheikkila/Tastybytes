import Foundation
import Models
internal import Supabase

struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient

    func getUser() async throws -> Profile.Account {
        let response = try await client.auth.session
        let (roles, permissions) = try decodeClaimsFromAccessToken(response.accessToken)
        return .init(id: .init(rawValue: response.user.id), email: response.user.email, roles: roles, permissions: permissions)
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
            credentials: .init(
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
            case .initialSession: session != nil ? .authenticated : .unauthenticated
            case .signedIn: .authenticated
            case .signedOut: .unauthenticated
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

extension AsyncSequence where Self: Sendable {
    func eraseToStream() -> AsyncStream<Element> {
        AsyncStream(self)
    }
}

private func decodeClaimsFromAccessToken(_ jwt: String) throws -> (roles: [Role.Name], permissions: [Permission.Name]) {
    enum DecodeErrors: Error {
        case badToken
        case other
        case missingAuthData
    }

    func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw DecodeErrors.badToken
        }
        return decoded
    }

    func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
        guard let payload = json as? [String: Any] else {
            throw DecodeErrors.other
        }
        return payload
    }

    let segments = jwt.components(separatedBy: ".")
    guard segments.count >= 2 else {
        throw DecodeErrors.badToken
    }

    let payload = try decodeJWTPart(segments[1])

    guard let authRoles = payload["auth_roles"] as? [String],
          let authPermissions = payload["auth_permissions"] as? [String]
    else {
        throw DecodeErrors.missingAuthData
    }

    let roles: [Role.Name] = authRoles.compactMap { .init(rawValue: $0) }
    let permissions: [Permission.Name] = authPermissions.compactMap { .init(rawValue: $0) }

    return (roles: roles, permissions: permissions)
}
