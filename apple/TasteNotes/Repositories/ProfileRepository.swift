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
    func uploadAvatar(id: UUID, data: Data) async throws -> Void
    func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Void, Error>
    func deleteCurrentAccount() async throws -> Void
    func updateSettings(id: UUID, update: ProfileSettings.Update) async throws -> ProfileSettings
}


struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    private let tableName = Profile.getQuery(.tableName)
    private let saved = Profile.getQuery(.saved(false))

    func getById(id: UUID) async throws -> Profile {
        print(Profile.getQuery(.extended(false)))
        return try await client
            .database
            .from(tableName)
            .select(columns: Profile.getQuery(.extended(false)))
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
    
    func updateSettings(id: UUID, update: ProfileSettings.Update) async throws -> ProfileSettings {
        return try await client
            .database
            .from(ProfileSettings.getQuery(.tableName))
            .update(
                values: update,
                returning: .representation
            )
            .eq(column: "id", value: id.uuidString.lowercased())
            .select(columns: Profile.getQuery(.saved(false)))
            .single()
            .execute()
            .decoded(to: ProfileSettings.self)
    }
    
    func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: "fnc__upsert_push_notification_token", params: token)
                .execute()
            return .success(Void())
        } catch {
            return .failure(error)
        }
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
    
    func uploadAvatar(id: UUID, data: Data) async throws -> Void {
        let file = File(
            name: "avatar.jpeg", data: data, fileName: "avatar.jpeg", contentType: "image/jpeg")
        
        _ = try await client
            .storage
            .from(id: "avatars")
            .upload(
                path: "\(id.uuidString.lowercased())/avatar.jpeg", file: file, fileOptions: nil)
    }
    
    func deleteCurrentAccount() async throws -> Void {
        try await client
            .database
            .rpc(fn: "fnc__delete_current_user")
            .execute()
    }
}

