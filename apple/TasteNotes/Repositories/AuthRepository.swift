import Foundation
import GoTrue
import SupabaseStorage
import Supabase

protocol AuthRepository {
    func getCurrentUserId() -> UUID
    func getCurrentUser() -> User?
    func logOut() async -> Result<Void, Error>
    func sendEmailVerification(email: String) async -> Result<Void, Error>
    func sendMagicLink(email: String) async -> Result<Void, Error>
    func signUp(email: String, password: String) async -> Result<Void, Error>
    func signIn(email: String, password: String) async -> Result<Void, Error>
    func sendPasswordResetEmail(email: String) async -> Result<Void, Error>
}

struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient
    
    func getCurrentUserId() -> UUID {
        guard let user = client
            .auth
            .session?
            .user
            .id else { return UUID() } // TODO: Come up with a better way to handle this returning nil on logout
        return user
    }
    
    func getCurrentUser() -> User? {
        return client
            .auth
            .session?
            .user
    }
    
    func logOut() async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .signOut()
            
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
    
    func sendMagicLink(email: String) async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .signIn(email: email)
            
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
    
    func signUp(email: String, password: String) async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .signUp(email: email, password: password)
            
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
    
    func signIn(email: String, password: String) async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .signIn(email: email, password: password)
            
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
    
    func sendPasswordResetEmail(email: String) async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .resetPasswordForEmail(email)
            
            return .success(Void())
        }
        catch {
            return .failure(error)
        }
    }
    
    func sendEmailVerification(email: String) async -> Result<Void, Error> {
        do {
            try await client
                .auth
                .update(user: UserAttributes(email: email))
            
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
}
