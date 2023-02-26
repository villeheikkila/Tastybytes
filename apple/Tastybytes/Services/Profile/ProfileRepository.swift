import Foundation
import Realtime
import Supabase
import SupabaseStorage

protocol ProfileRepository {
  func getById(id: UUID) async -> Result<Profile, Error>
  func getCurrentUser() async -> Result<Profile.Extended, Error>
  func update(update: Profile.UpdateRequest) async -> Result<Profile.Extended, Error>
  func currentUserExport() async -> Result<String, Error>
  func search(searchTerm: String, currentUserId: UUID?) async -> Result<[Profile], Error>
  func uploadAvatar(userId: UUID, data: Data) async -> Result<String, Error>
  func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Void, Error>
  func deleteCurrentAccount() async -> Result<Void, Error>
  func updateSettings(update: ProfileSettings.UpdateRequest) async -> Result<ProfileSettings, Error>
}

struct SupabaseProfileRepository: ProfileRepository {
  let client: SupabaseClient

  func getById(id: UUID) async -> Result<Profile, Error> {
    do {
      let response: Profile = try await client
        .database
        .from(Profile.getQuery(.tableName))
        .select(columns: Profile.getQuery(.minimal(false)))
        .eq(column: "id", value: id.uuidString.lowercased())
        .limit(count: 1)
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func getCurrentUser() async -> Result<Profile.Extended, Error> {
    do {
      let response: Profile.Extended = try await client
        .database
        .rpc(fn: "fnc__get_current_profile")
        .select(columns: Profile.getQuery(.extended(false)))
        .limit(count: 1)
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func update(update: Profile.UpdateRequest) async -> Result<Profile.Extended, Error> {
    do {
      let response: Profile.Extended = try await client
        .database
        .from(Profile.getQuery(.tableName))
        .update(
          values: update,
          returning: .representation
        )
        /*
         Supabase responds with status code 46 if where clause is not specified for an update.
         However we do not need top pass the real id here because it is assigned by trigger.
         RLS makes sure that user can only ever update their own profiles.
         */
        .notEquals(column: "id", value: UUID().uuidString)
        .select(columns: Profile.getQuery(.extended(false)))
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func updateSettings(update: ProfileSettings.UpdateRequest) async -> Result<ProfileSettings, Error> {
    do {
      let response: ProfileSettings = try await client
        .database
        .from(ProfileSettings.getQuery(.tableName))
        .update(
          values: update,
          returning: .representation
        )
        /*
         Supabase responds with status code 46 if where clause is not specified for an update.
         However we do not need top pass the real id here because it is assigned by trigger.
         RLS makes sure that user can only ever update their own profiles.
         */
        .notEquals(column: "id", value: UUID().uuidString)
        .select(columns: ProfileSettings.getQuery(.saved(false)))
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func uploadPushNotificationToken(token: Profile.PushNotificationToken) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__upsert_push_notification_token", params: token)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func currentUserExport() async -> Result<String, Error> {
    do {
      let csv: String = try await client
        .database
        .rpc(fn: "fnc__export_data")
        .csv()
        .execute()
        .value

      return .success(csv)
    } catch {
      return .failure(error)
    }
  }

  func search(searchTerm: String, currentUserId: UUID? = nil) async -> Result<[Profile], Error> {
    do {
      let query = client
        .database
        .from(Profile.getQuery(.tableName))
        .select(columns: Profile.getQuery(.minimal(false)))
        .ilike(column: "search", value: "%\(searchTerm)%")

      if let currentUserId {
        let response: [Profile] = try await query.not(column: "id", operator: .eq, value: currentUserId.uuidString)
          .execute().value
        return .success(response)
      }

      let response: [Profile] = try await query.execute().value
      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func uploadAvatar(userId: UUID, data: Data) async -> Result<String, Error> {
    do {
      let fileName = "\(UUID().uuidString.lowercased()).jpeg"
      let file = File(
        name: fileName, data: data, fileName: fileName, contentType: "image/jpeg"
      )
      _ = try await client
        .storage
        .from(id: "avatars")
        .upload(
          path: "\(userId.uuidString.lowercased())/\(fileName)", file: file, fileOptions: nil
        )

      return .success(fileName)
    } catch {
      return .failure(error)
    }
  }

  func deleteCurrentAccount() async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__delete_current_user")
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}
