import Supabase

public protocol AuthRepository {
    func getUser() async -> Result<User, Error>
    func logOut() async -> Result<Void, Error>
    func sendEmailVerification(email: String) async -> Result<Void, Error>
    func sendMagicLink(email: String) async -> Result<Void, Error>
    func signUp(username: String, email: String, password: String) async -> Result<Void, Error>
    func signIn(email: String, password: String) async -> Result<Void, Error>
    func signInWithApple(token: String) async -> Result<Void, Error>
    func sendPasswordResetEmail(email: String) async -> Result<Void, Error>
    func updatePassword(newPassword: String) async -> Result<Void, Error>
}
