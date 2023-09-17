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

extension Profile {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profiles.rawValue
        let minimal = "id, is_private, preferred_name, avatar_file, joined_at"
        let saved =
            "id, first_name, last_name, username, avatar_file, name_display, preferred_name, is_private, is_onboarded, joined_at"
        let avatarBucketId = "avatars"

        switch queryType {
        case .tableName:
            return tableName
        case .avatarBucket:
            return avatarBucketId
        case let .minimal(withTableName):
            return queryWithTableName(tableName, minimal, withTableName)
        case let .extended(withTableName):
            return queryWithTableName(
                tableName,
                [saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case avatarBucket
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
    }
}

extension Role {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.roles.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, Permission.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension Permission {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.permissions.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}

extension ProfileWishlist {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profileWishlistItems.rawValue
        let saved = "created_by"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension ProfileSettings {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profileSettings.rawValue
        let saved =
            """
            id, send_reaction_notifications, send_tagged_check_in_notifications,\
            send_friend_request_notifications, send_comment_notifications
            """

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}

extension CategoryStatistics {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "id, name, icon, count"
        }
    }
}

extension Contributions {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "products, companies, brands, sub_brands, barcodes"
        }
    }
}

extension SubcategoryStatistics {
    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "id, name, count"
        }
    }
}

public extension AvatarURL {
    var avatarUrl: URL? {
        guard let avatarFile else { return nil }
        return URL(bucketId: .avatars, fileName: "\(id.uuidString.lowercased())/\(avatarFile)")
    }
}
