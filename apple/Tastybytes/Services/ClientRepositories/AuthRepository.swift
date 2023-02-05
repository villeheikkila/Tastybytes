import Foundation
import GoTrue
import Supabase
import SupabaseStorage

protocol AuthRepository {
  func getUser() async -> Result<User, Error>
  func logOut() async -> Result<Void, Error>
  func sendEmailVerification(email: String) async -> Result<Void, Error>
  func sendMagicLink(email: String) async -> Result<Void, Error>
  func signUp(email: String, password: String) async -> Result<Void, Error>
  func signIn(email: String, password: String) async -> Result<Void, Error>
  func sendPasswordResetEmail(email: String) async -> Result<Void, Error>
  func updatePassword(newPassword: String) async -> Result<Void, Error>
}

struct SupabaseAuthRepository: AuthRepository {
  let client: SupabaseClient

  func getUser() async -> Result<User, Error> {
    do {
      let response = try await client.auth.session.user

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func logOut() async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .signOut()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func sendMagicLink(email: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .signInWithOTP(email: email)

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func signUp(email: String, password: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .signUp(email: email, password: password)

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func updatePassword(newPassword: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth.update(user: UserAttributes(password: newPassword))
      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func signIn(email: String, password: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .signIn(email: email, password: password)

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func sendPasswordResetEmail(email: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .resetPasswordForEmail(email)

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func sendEmailVerification(email: String) async -> Result<Void, Error> {
    do {
      try await client
        .auth
        .update(user: UserAttributes(email: email))

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}
