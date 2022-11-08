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
    func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Bool, Error>
    func deleteCurrentAccount() async throws -> Void
    func updateSettings(id: UUID, update: ProfileSettings.Update) async throws -> ProfileSettings
}

let checkInFragment = "check_ins (id, rating, review, image_url, created_at, serving_styles (id, name), profiles (id, username, first_name, last_name, avatar_url, name_display), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name, logo_url))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, first_name, last_name, avatar_url, name_display)), check_in_flavors (flavors (id, name)), check_in_tagged_profiles (profiles (id, username, first_name, last_name, avatar_url, name_display)))"

let profileSettingsFragment = "profile_settings (id, color_scheme, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications)"

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    private let tableName = "profiles"
    private let saved = "id, username, first_name, last_name, avatar_url, name_display"
    private let fullSaved = "id, username, first_name, last_name, avatar_url, name_display, \(profileSettingsFragment), notifications (id, message, created_at, check_in_reactions (id, profiles (id, username, avatar_url, name_display), \(checkInFragment)), check_ins (id, rating, review, image_url, created_at, serving_styles (id, name), profiles (id, username, first_name, last_name, avatar_url, name_display), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name, logo_url))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, first_name, last_name, avatar_url, name_display)), check_in_flavors (flavors (id, name)), check_in_tagged_profiles (profiles (id, username, first_name, last_name, avatar_url, name_display)), product_variants (id, companies (id, name, logo_url))), friends (id, status, sender:user_id_1 (id, username, first_name, last_name, avatar_url, name_display), receiver:user_id_2 (id, username, first_name, last_name, avatar_url, name_display))), roles (id, name, permissions (id, name))"
    
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
    
    func updateSettings(id: UUID, update: ProfileSettings.Update) async throws -> ProfileSettings {
        return try await client
            .database
            .from("profile_settings")
            .update(
                values: update,
                returning: .representation
            )
            .eq(column: "id", value: id.uuidString.lowercased())
            .select(columns: "id, color_scheme, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications")
            .single()
            .execute()
            .decoded(to: ProfileSettings.self)
    }
    
    func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Bool, Error> {
        do {
            let response = try await client
                .database
                .from("profile_push_notification_tokens")
                .upsert(
                    values: token,
                    ignoreDuplicates: true
                )
                .execute()
            print(response)
            return .success(true)
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

