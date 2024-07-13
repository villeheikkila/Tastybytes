import Foundation
import Models
internal import Supabase

public protocol AuthRepository: Sendable {
    func getUser() async throws -> Models.User
    func signInFromUrl(url: URL) async throws
    func logOut() async throws
    func sendEmailVerification(email: String) async throws
    func sendMagicLink(email: String) async throws
    func signInWithApple(token: String, nonce: String) async throws
    func authStateListener() async throws -> AsyncStream<AuthState>
    func refreshSession() async throws
}
