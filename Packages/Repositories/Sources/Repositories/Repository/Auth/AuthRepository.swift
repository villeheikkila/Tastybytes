import Foundation
import Models
import Supabase

public protocol AuthRepository: Sendable {
    func getUser() async -> Result<User, Error>
    func signInFromUrl(url: URL) async -> Result<Void, Error>
    @discardableResult func logOut() async -> Result<Void, Error>
    func sendEmailVerification(email: String) async -> Result<Void, Error>
    func sendMagicLink(email: String) async -> Result<Void, Error>
    func signInWithApple(token: String, nonce: String) async -> Result<Void, Error>
    func authStateListener() async -> AsyncStream<AuthState>
    func refreshSession() async -> Result<Void, Error>
}
