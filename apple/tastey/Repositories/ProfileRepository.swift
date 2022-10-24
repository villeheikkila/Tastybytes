import Foundation
import GoTrue
import SupabaseStorage
import Supabase
import Realtime

protocol ProfileRepository {
    func getById(id: UUID) async throws -> Profile
    func update(id: UUID, update: Profile.Update) async throws -> Profile
    func currentUserExport() async throws -> String
    func search(searchTerm: String, currentUserId: UUID) async throws -> [Profile]
    func uploadAvatar(id: UUID, data: Data, completion: @escaping (Result<Any, Error>) -> Void) async throws -> Void
    func deleteCurrentAccount() async throws -> Void
    func notificationChannel() -> Channel
}

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    private let tableName = "profiles"
    private let saved = "id, username, first_name, last_name, avatar_url, name_display"
    private let fullSaved = "id, username, first_name, last_name, avatar_url, name_display, color_scheme, notifications (id, message, created_at), roles (id, name, permissions (id, name))"
    
    func getById(id: UUID) async throws -> Profile {
        return try await client
            .database
            .from(tableName)
            .select(columns: fullSaved)
            .eq(column: "id", value: id.uuidString.lowercased())
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func update(id: UUID, update: Profile.Update) async throws -> Profile {
        return try await client
            .database
            .from(tableName)
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
        let response =  try await client
            .database
            .rpc(fn: "fnc__export_data")
            .csv()
            .execute()
        
        guard let csv = String(data: response.data, encoding: String.Encoding.utf8) else {
            throw ProfileError.csvExportFailure
        }
        
        return csv
    }
    
    func search(searchTerm: String, currentUserId: UUID) async throws -> [Profile] {
        return try await client
            .database
            .from(tableName)
            .select(columns: saved)
            .ilike(column: "search", value: "%\(searchTerm)%")
            .not(column: "id", operator: .eq, value: currentUserId.uuidString)
            .execute()
            .decoded(to: [Profile].self)
    }
    
    func uploadAvatar(id: UUID, data: Data, completion: @escaping (Result<Any, Error>) -> Void) async throws -> Void {
        let file = File(
            name: "avatar.jpeg", data: data, fileName: "avatar.jpeg", contentType: "image/jpeg")
        
        client
            .storage
            .from(id: "avatars")
            .upload(
                path: "\(id.uuidString.lowercased())/avatar.jpeg", file: file, fileOptions: nil,
                completion: completion)
    }
    
    func deleteCurrentAccount() async throws -> Void {
        try await client
            .database
            .rpc(fn: "fnc__delete_current_user")
            .execute()
    }
    
    func notificationChannel() -> Channel {
        return client
            .realtime
            .channel(.table("notifications", schema: "public"))
    }
}

