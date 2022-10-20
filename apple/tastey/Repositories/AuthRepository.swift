import Foundation
import GoTrue
import SupabaseStorage

protocol AuthRepository {
    func getCurrentUserId() -> UUID
    func getCurrentUser() -> User
    func logOut() async throws -> Void
    func sendEmailVerification(email: String) async throws -> Void
}

struct SupabaseAuthRepository: AuthRepository {
    let auth = Supabase.client.auth
    
    func getCurrentUserId() -> UUID {
        guard let user = Supabase.client.auth.session?.user.id else { fatalError("User session is missing! This function should only be called in views where user session is already active.)") }
        return user
    }
    
    func getCurrentUser() -> User {
        guard let user = Supabase.client.auth.session?.user else { fatalError("User session is missing! This function should only be called in views where user session is already active.)") }
        return user
    }

    func logOut() async throws -> Void {
        try await Supabase.client.auth.signOut()
    }

    func sendEmailVerification(email: String) async throws -> Void {
        try await Supabase.client.auth.update(user: UserAttributes(email: email))
    }
}
