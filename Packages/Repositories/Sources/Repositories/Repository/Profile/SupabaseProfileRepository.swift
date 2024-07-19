import Foundation
import Models
internal import Supabase

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: UUID) async throws -> Profile {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.minimal(false)))
            .eq("id", value: id.uuidString.lowercased())
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: UUID) async throws -> Profile.Detailed {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.detailed(false)))
            .eq("id", value: id.uuidString.lowercased())
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Profile] {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.minimal(false)))
            .order("joined_at", ascending: false)
            .execute()
            .value
    }

    func getContributions(id: UUID) async throws -> Profile.Contributions {
        try await client
            .from(.profiles)
            .select(Profile.Contributions.getQuery(.joined(false)))
            .eq("id", value: id.uuidString.lowercased())
            .not("sub_brands.name", operator: .is, value: AnyJSON.null)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getCurrentUser() async throws -> Profile.Extended {
        try await client
            .rpc(fn: .getCurrentProfile)
            .select(Profile.getQuery(.extended(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(update: Profile.UpdateRequest) async throws -> Profile.Extended {
        try await client
            .from(.profiles)
            .update(update, returning: .representation)
            .eq("id", value: update.id)
            .select(Profile.getQuery(.extended(false)))
            .single()
            .execute()
            .value
    }

    func updateSettings(update: Profile.SettingsUpdateRequest) async throws -> Profile.Settings {
        try await client
            .from(.profileSettings)
            .update(update, returning: .representation)
            .eq("id", value: update.id)
            .select(Profile.Settings.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getCategoryStatistics(userId: UUID) async throws -> [CategoryStatistics] {
        try await client
            .rpc(
                fn: .getCategoryStats,
                params: CategoryStatistics.CategoryStatisticsParams(id: userId)
            )
            .select(CategoryStatistics.getQuery(.value))
            .execute()
            .value
    }

    func getSubcategoryStatistics(userId: UUID, categoryId: Int) async throws -> [SubcategoryStatistics] {
        try await client
            .rpc(
                fn: .getSubcategoryStats,
                params: SubcategoryStatistics.SubcategoryStatisticsParams(userId: userId, categoryId: categoryId)
            )
            .select(SubcategoryStatistics.getQuery(.value))
            .execute()
            .value
    }

    func currentUserExport() async throws -> String {
        let csv = try await client
            .rpc(fn: .exportData)
            .csv()
            .execute()
            .data

        guard let string = String(data: csv, encoding: .utf8) else {
            throw DataConversionError.invalidData
        }

        return string
    }

    func deleteUserAsSuperAdmin(_ profile: Profile) async throws {
        struct DeleteRequestParam: Encodable {
            let id: UUID

            public init(profile: Profile) {
                id = profile.id
            }

            enum CodingKeys: String, CodingKey {
                case id = "p_id"
            }
        }

        try await client
            .rpc(fn: .deleteUserAsSuperAdmin, params: DeleteRequestParam(profile: profile))
            .execute()
    }

    func search(searchTerm: String, currentUserId: UUID? = nil) async throws -> [Profile] {
        let query = client
            .from(.profiles)
            .select(Profile.getQuery(.minimal(false)))
            .ilike("search", pattern: "%\(searchTerm)%")

        if let currentUserId {
            return try await query
                .not("id", operator: .eq, value: currentUserId.uuidString)
                .execute().value
        }

        return try await query.execute().value
    }

    func uploadAvatar(userId: UUID, data: Data) async throws -> ImageEntity {
        let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
        let path = "\(userId.uuidString.lowercased())/\(fileName)"

        try await client
            .storage
            .from(.avatars)
            .upload(path: path, file: data, options: .init(contentType: "image/jpeg"))

        return try await imageEntityRepository.getByFileName(from: .avatars, fileName: path)
    }

    func deleteCurrentAccount() async throws {
        try await client
            .rpc(fn: .deleteCurrentUser)
            .execute()
    }

    func checkIfUsernameIsAvailable(username: String) async throws -> Bool {
        try await client
            .rpc(
                fn: .checkIfUsernameIsAvailable,
                params: Profile.UsernameCheckRequest(username: username)
            )
            .execute()
            .value
    }

    func getTimePeriodStatistics(userId: UUID, timePeriod: StatisticsTimePeriod) async throws -> TimePeriodStatistic {
        try await client
            .rpc(
                fn: .getTimePeriodStatistics,
                params: TimePeriodStatistic.RequestParams(userId: userId, timePeriod: timePeriod)
            )
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getNumberOfCheckInsByDay(_ request: NumberOfCheckInsByDayRequest) async throws -> [CheckInsPerDay] {
        try await client
            .rpc(fn: .getNumberOfCheckInsByDay, params: request)
            .execute()
            .value
    }

    func getNumberOfCheckInsByLocation(userId: UUID) async throws -> [Profile.TopLocations] {
        struct Request: Encodable {
            let profileId: UUID

            enum CodingKeys: String, CodingKey {
                case profileId = "p_profile_id"
            }
        }
        return try await client
            .rpc(fn: .getNumberOfCheckInsByLocation, params: Request(profileId: userId))
            .select(Location.getQuery(.topLocations))
            .limit(20)
            .order("check_ins_count", ascending: false)
            .execute()
            .value
    }
}
