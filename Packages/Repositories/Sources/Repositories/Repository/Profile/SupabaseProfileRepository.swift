import Foundation
import Models
internal import Supabase

struct SupabaseProfileRepository: ProfileRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Profile.Id) async throws -> Profile.Saved {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.minimal(false)))
            .eq("id", value: id.uuidString)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Profile.Id) async throws -> Profile.Detailed {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.detailed(false)))
            .eq("id", value: id.uuidString)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Profile.Saved] {
        try await client
            .from(.profiles)
            .select(Profile.getQuery(.minimal(false)))
            .order("joined_at", ascending: false)
            .execute()
            .value
    }

    func getContributions(id: Profile.Id) async throws -> Profile.Contributions {
        try await client
            .from(.profiles)
            .select(Profile.Contributions.getQuery(.joined(false)))
            .eq("id", value: id.uuidString)
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
            .eq("id", value: update.id.rawValue)
            .select(Profile.getQuery(.extended(false)))
            .single()
            .execute()
            .value
    }

    func updateSettings(update: Profile.SettingsUpdateRequest) async throws -> Profile.Settings {
        try await client
            .from(.profileSettings)
            .update(update, returning: .representation)
            .eq("id", value: update.id.rawValue)
            .select(Profile.Settings.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getCategoryStatistics(id: Profile.Id) async throws -> [Profile.CategoryStatistics] {
        try await client
            .rpc(
                fn: .getCategoryStats,
                params: ["p_user_id": id.rawValue]
            )
            .select(Profile.CategoryStatistics.getQuery(.value))
            .execute()
            .value
    }

    func getSubcategoryStatistics(id: Profile.Id, categoryId: Models.Category.Id) async throws -> [Profile.SubcategoryStatistics] {
        try await client
            .rpc(
                fn: .getSubcategoryStats,
                params: Profile.SubcategoryStatistics.SubcategoryStatisticsParams(userId: id, categoryId: categoryId)
            )
            .select(Profile.SubcategoryStatistics.getQuery(.value))
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

    func deleteUserAsSuperAdmin(_ id: Profile.Id) async throws {
        struct DeleteRequestParam: Encodable {
            let id: Profile.Id

            public init(id: Profile.Id) {
                self.id = id
            }

            enum CodingKeys: String, CodingKey {
                case id = "p_id"
            }
        }

        try await client
            .rpc(fn: .deleteUserAsSuperAdmin, params: DeleteRequestParam(id: id))
            .execute()
    }

    func search(searchTerm: String, currentUserId: Profile.Id? = nil) async throws -> [Profile.Saved] {
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

    func uploadAvatar(id: Profile.Id, data: Data, width: Int, height: Int, blurHash: String?) async throws -> ImageEntity.Saved {
        let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
        let path = "\(id.uuidString.lowercased())/\(fileName)"
        let metadata = try? ["width": AnyJSON(width), "height": AnyJSON(height), "blur_hash": AnyJSON(blurHash)]
        try await client
            .storage
            .from(.avatars)
            .upload(path, data: data, options: .init(cacheControl: "max-age=3600", contentType: "image/jpeg", metadata: metadata))

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

    func getTimePeriodStatistics(id: Profile.Id, timePeriod: StatisticsTimePeriod) async throws -> Profile.TimePeriodStatistic {
        try await client
            .rpc(
                fn: .getTimePeriodStatistics,
                params: Profile.TimePeriodStatistic.RequestParams(userId: id, timePeriod: timePeriod)
            )
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getNumberOfCheckInsByDay(_ request: NumberOfCheckInsByDayRequest) async throws -> [Profile.CheckInsPerDay] {
        try await client
            .rpc(fn: .getNumberOfCheckInsByDay, params: request)
            .execute()
            .value
    }

    func getNumberOfCheckInsByLocation(id: Profile.Id) async throws -> [Profile.TopLocations] {
        struct Request: Encodable {
            let id: Profile.Id

            enum CodingKeys: String, CodingKey {
                case id = "p_profile_id"
            }
        }
        return try await client
            .rpc(fn: .getNumberOfCheckInsByLocation, params: Request(id: id))
            .select(Location.getQuery(.topLocations))
            .limit(20)
            .order("check_ins_count", ascending: false)
            .execute()
            .value
    }
}
