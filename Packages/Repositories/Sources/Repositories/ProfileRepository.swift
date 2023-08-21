import Foundation
import Models
import Realtime
import Supabase
import SupabaseStorage

public protocol ProfileRepository {
    func getById(id: UUID) async -> Result<Profile, Error>
    func getCurrentUser() async -> Result<Profile.Extended, Error>
    func update(update: Profile.UpdateRequest) async -> Result<Profile.Extended, Error>
    func currentUserExport() async -> Result<String, Error>
    func search(searchTerm: String, currentUserId: UUID?) async -> Result<[Profile], Error>
    func uploadAvatar(userId: UUID, data: Data) async -> Result<String, Error>
    func deleteCurrentAccount() async -> Result<Void, Error>
    func updateSettings(update: ProfileSettings.UpdateRequest) async -> Result<ProfileSettings, Error>
    func getContributions(userId: UUID) async -> Result<Contributions, Error>
    func getCategoryStatistics(userId: UUID) async -> Result<[CategoryStatistics], Error>
    func getSubcategoryStatistics(userId: UUID, categoryId: Int) async -> Result<[SubcategoryStatistics], Error>
    func checkIfUsernameIsAvailable(username: String) async -> Result<Bool, Error>
}

public struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient

    public func getById(id: UUID) async -> Result<Profile, Error> {
        do {
            let response: Profile = try await client
                .database
                .from(.profiles)
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

    public func getCurrentUser() async -> Result<Profile.Extended, Error> {
        do {
            let response: Profile.Extended = try await client
                .database
                .rpc(fn: .getCurrentProfile)
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

    public func update(update: Profile.UpdateRequest) async -> Result<Profile.Extended, Error> {
        do {
            let response: Profile.Extended = try await client
                .database
                .from(.profiles)
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

    public func updateSettings(update: ProfileSettings.UpdateRequest) async -> Result<ProfileSettings, Error> {
        do {
            let response: ProfileSettings = try await client
                .database
                .from(.profileSettings)
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

    public func getContributions(userId: UUID) async -> Result<Contributions, Error> {
        do {
            let response: Contributions = try await client
                .database
                .rpc(fn: .getContributionsByUser, params: Contributions.ContributionsParams(id: userId))
                .select(columns: Contributions.getQuery(.value))
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func getCategoryStatistics(userId: UUID) async -> Result<[CategoryStatistics], Error> {
        do {
            let response: [CategoryStatistics] = try await client
                .database
                .rpc(
                    fn: .getCategoryStats,
                    params: CategoryStatistics.CategoryStatisticsParams(id: userId)
                )
                .select(columns: CategoryStatistics.getQuery(.value))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func getSubcategoryStatistics(userId: UUID,
                                         categoryId: Int) async -> Result<[SubcategoryStatistics], Error>
    {
        do {
            let response: [SubcategoryStatistics] = try await client
                .database
                .rpc(
                    fn: .getSubcategoryStats,
                    params: SubcategoryStatistics.SubcategoryStatisticsParams(userId: userId, categoryId: categoryId)
                )
                .select(columns: SubcategoryStatistics.getQuery(.value))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func currentUserExport() async -> Result<String, Error> {
        do {
            let csv: String = try await client
                .database
                .rpc(fn: .exportData)
                .csv()
                .execute()
                .value

            return .success(csv)
        } catch {
            return .failure(error)
        }
    }

    public func search(searchTerm: String, currentUserId: UUID? = nil) async -> Result<[Profile], Error> {
        do {
            let query = client
                .database
                .from(.profiles)
                .select(columns: Profile.getQuery(.minimal(false)))
                .ilike(column: "search", value: "%\(searchTerm)%")

            if let currentUserId {
                let response: [Profile] = try await query
                    .not(column: "id", operator: .eq, value: currentUserId.uuidString)
                    .execute().value
                return .success(response)
            }

            let response: [Profile] = try await query.execute().value
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func uploadAvatar(userId: UUID, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
            let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.avatars)
                .upload(
                    path: "\(userId.uuidString.lowercased())/\(fileName)",
                    file: file,
                    fileOptions: nil
                )

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }

    public func deleteCurrentAccount() async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .deleteCurrentUser)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func checkIfUsernameIsAvailable(username: String) async -> Result<Bool, Error> {
        do {
            let result: Bool = try await client
                .database
                .rpc(
                    fn: .checkIfUsernameIsAvailable,
                    params: Profile.UsernameCheckRequest(username: username)
                )
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
