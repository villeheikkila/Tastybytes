import Foundation
import GoTrue
import SupabaseStorage
import Supabase

protocol AuthRepository {
    func getCurrentUserId() -> UUID
    func getCurrentUser() -> User?
    func logOut() async -> Result<Void, Error>
    func sendEmailVerification(email: String) async -> Result<Void, Error>
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
