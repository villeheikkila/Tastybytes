import Foundation
import GoTrue
import SupabaseStorage
import Supabase

protocol AuthRepository {
    func getCurrentUserId() -> UUID
    func getCurrentUser() -> User?
    func logOut() async throws -> Void
    func sendEmailVerification(email: String) async throws -> Void
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
    
    func logOut() async throws -> Void {
        try await client
            .auth
            .signOut()
    }
    
    func sendEmailVerification(email: String) async throws -> Void {
        try await client
            .auth
            .update(user: UserAttributes(email: email))
    }
}
