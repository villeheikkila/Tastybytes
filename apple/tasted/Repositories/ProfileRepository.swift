import Foundation
import GoTrue
import SupabaseStorage

struct SupabaseProfileRepository {
    func loadProfileById(id: UUID) async throws -> Profile {
        return try await API.supabase.database
            .from("profiles")
            .select(columns: "id, username, first_name, last_name, avatar_url")
            .eq(column: "id", value: id.uuidString.lowercased())
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func updateProfile(id: UUID, update: ProfileUpdate) async throws -> Profile {
        return try await API.supabase.database.from("profiles")
            .update(
                values: update,
                returning: .representation
            )
            .eq(column: "id", value: id.uuidString.lowercased())
            .select(columns: "id, username, first_name, last_name, avatar_url")
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func currentUserExport() async throws -> String {
        let response =  try await API.supabase.database.rpc(fn: "fnc__export_data").csv().execute()
        guard let csv = String(data: response.data, encoding: String.Encoding.utf8) else {
            throw ProfileError.csvExportFailure
        }
        return csv
    }
    
    func uploadAvatar(id: UUID, data: Data, completion: @escaping (Result<Any, Error>) -> Void) async throws -> Void {
        let file = File(
            name: "avatar.jpeg", data: data, fileName: "avatar.jpeg", contentType: "image/jpeg")
                
        API.supabase.storage
            .from(id: "avatars")
            .upload(
                path: "\(id.uuidString.lowercased())/avatar.jpeg", file: file, fileOptions: nil,
                completion: completion)
    }
    
    func deleteCurrentAccount() async throws -> Void {
        try await API.supabase.database.rpc(fn: "fnc__delete_current_user").execute()
    }
    
    func logOut() async throws -> Void {
        try await API.supabase.auth.signOut()
    }
    
    func sendEmailVerification(email: String) async throws -> Void {
        try await API.supabase.auth.update(user: UserAttributes(email: email))
    }
}

