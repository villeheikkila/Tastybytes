import Foundation
import GoTrue
import SupabaseStorage
import Supabase

protocol AuthRepository {
    func getCurrentUserId() -> UUID
    func getCurrentUser() -> User
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
            .id else { fatalError("User session is missing! This function should only be called in views where user session is already active.)") }
        return user
    }
    
    func getCurrentUser() -> User {
        guard let user = client
            .auth
            .session?
            .user else { fatalError("User session is missing! This function should only be called in views where user session is already active.)") }
        return user
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
