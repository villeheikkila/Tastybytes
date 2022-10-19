import Foundation
import GoTrue
import SupabaseStorage

struct SupabaseProfileRepository {
    private let database = Supabase.client.database
    private let tableName = "profiles"
    private let saved = "id, username, first_name, last_name, avatar_url, name_display"
    
    func loadProfileById(id: UUID) async throws -> Profile {
        return try await database
            .from(tableName)
            .select(columns: saved)
            .eq(column: "id", value: id.uuidString.lowercased())
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: Profile.self)
    }
    
    func updateProfile(id: UUID, update: ProfileUpdate) async throws -> Profile {
        return try await database
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
        let response =  try await database
            .rpc(fn: "fnc__export_data")
            .csv()
            .execute()
        
        guard let csv = String(data: response.data, encoding: String.Encoding.utf8) else {
            throw ProfileError.csvExportFailure
        }
        
        return csv
    }
    
    func search(searchTerm: String) async throws -> [Profile] {
        return try await database
            .from(tableName)
            .select(columns: saved)
            .ilike(column: "search", value: "%\(searchTerm)%")
            .not(column: "id", operator: .eq, value: SupabaseAuthRepository().getCurrentUserId().uuidString)
            .execute()
            .decoded(to: [Profile].self)
    }
    
    func loadFriendsByUsername(username: String) async throws -> [Profile] {
        struct GetFriendsByUsernamParams: Codable {
            let p_username: String
            init(username: String) {
                self.p_username = username
            }
        }
        return try await database
            .rpc(fn: "fnc__get_friends_by_username", params: GetFriendsByUsernamParams(username: username))
            .select(columns: saved)
            .execute()
            .decoded(to: [Profile].self)
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
        try await database
            .rpc(fn: "fnc__delete_current_user")
            .execute()
    }
}

