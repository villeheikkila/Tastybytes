import Foundation
import GoTrue
import SupabaseStorage

struct SupabaseProfileRepository {
    private let tableName = "profiles"
    private let saved = "id, username, first_name, last_name, avatar_url"
    
    func loadProfileById(id: UUID) async throws -> Profile {
        return try await Supabase.client.database
            .from(tableName)
            .select(columns: saved)
            .eq(column: "id", value: id.uuidString.lowercased())
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func updateProfile(id: UUID, update: ProfileUpdate) async throws -> Profile {
        return try await Supabase.client.database.from(tableName)
            .update(
                values: update,
                returning: .representation
            )
            .eq(column: "id", value: id.uuidString.lowercased())
            .select(columns: saved)
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func currentUserExport() async throws -> String {
        let response =  try await Supabase.client.database.rpc(fn: "fnc__export_data").csv().execute()
        guard let csv = String(data: response.data, encoding: String.Encoding.utf8) else {
            throw ProfileError.csvExportFailure
        }
        return csv
    }
    
    func uploadAvatar(id: UUID, data: Data, completion: @escaping (Result<Any, Error>) -> Void) async throws -> Void {
        let file = File(
            name: "avatar.jpeg", data: data, fileName: "avatar.jpeg", contentType: "image/jpeg")
                
        Supabase.client.storage
            .from(id: "avatars")
            .upload(
                path: "\(id.uuidString.lowercased())/avatar.jpeg", file: file, fileOptions: nil,
                completion: completion)
    }
    
    func deleteCurrentAccount() async throws -> Void {
        try await Supabase.client.database.rpc(fn: "fnc__delete_current_user").execute()
    }
}

