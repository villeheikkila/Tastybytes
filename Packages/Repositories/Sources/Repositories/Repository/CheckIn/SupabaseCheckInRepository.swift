import Foundation
import Models
internal import Supabase

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getActivityFeed(query: ActivityFeedQueryType) async throws -> [CheckIn.Joined] {
        let partialQuery = client
            .from(.viewActivityFeed)
            .select(CheckIn.getQuery(.joined(false)))

        let range = switch query {
        case let .paginated(from, to):
            partialQuery.range(from: from, to: to)
        case let .afterId(id):
            partialQuery.gt("id", value: id.rawValue)
        }

        return try await range
            .order("id", ascending: false)
            .execute()
            .value
    }

    func getByProfileId(id: Profile.Id, queryType: CheckInQueryType) async throws -> [CheckIn.Joined] {
        let queryBuilder = client
            .from(.checkIns)
            .select(CheckIn.getQuery(.joined(false)))

        let filter = queryBuilder
            .eq("created_by", value: id.uuidString.lowercased())

        let conditionalFilters = if case let .dateRange(_, _, dateRange) = queryType {
            filter.gte("check_in_at", value: dateRange.lowerBound.formatted(.iso8601))
                .lte("check_in_at", value: dateRange.upperBound.formatted(.iso8601))
        } else if case let .location(_, _, location) = queryType {
            filter.eq("location_id", value: location.id.rawValue)
        } else {
            filter
        }

        let ordered = conditionalFilters.order("check_in_at", ascending: false)

        let query = if case let .paginated(from, to) = queryType {
            ordered.range(from: from, to: to)
        } else if case let .dateRange(from, to, _) = queryType {
            ordered.range(from: from, to: to)
        } else if case let .location(from, to, _) = queryType {
            ordered.range(from: from, to: to)
        } else {
            ordered
        }

        return try await query
            .execute()
            .value
    }

    func getDetailed(id: CheckIn.Id) async throws -> CheckIn.Detailed {
        try await client
            .from(.checkIns)
            .select(CheckIn.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getByProductId(id: Product.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined] {
        try await client
            .from(segment.table)
            .select(CheckIn.getQuery(.joined(false)))
            .eq("product_id", value: id.rawValue)
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getDetailedCheckInImage(id: ImageEntity.Id) async throws -> ImageEntity.Detailed {
        try await client
            .from(.checkInImages)
            .select(CheckIn.getQuery(.imageDetailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getCheckInImages(id: Profile.Id, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn] {
        try await client
            .from(.checkInImages)
            .select(CheckIn.getQuery(.image(false)))
            .eq("created_by", value: id.rawValue)
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn] {
        try await client
            .from(.checkInImages)
            .select(CheckIn.getQuery(.image(false)))
            .eq(by.column, value: by.id)
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getByLocation(id: Location.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined] {
        try await client
            .from(segment.table)
            .select(CheckIn.getQuery(.joined(false)))
            .or("location_id.eq.\(id.rawValue),purchase_location_id.eq.\(id.rawValue)")
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getById(id: CheckIn.Id) async throws -> CheckIn.Joined {
        try await client
            .from(.checkIns)
            .select(CheckIn.getQuery(.joined(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func create(newCheckInParams: CheckIn.NewRequest) async throws -> CheckIn.Joined {
        try await client
            .rpc(fn: .createCheckIn, params: newCheckInParams)
            .select(CheckIn.getQuery(.joined(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(updateCheckInParams: CheckIn.UpdateRequest) async throws -> CheckIn.Joined {
        try await client
            .rpc(fn: .updateCheckIn, params: updateCheckInParams)
            .select(CheckIn.getQuery(.joined(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(id: CheckIn.Id) async throws {
        try await client
            .from(.checkIns)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func deleteAsModerator(id: CheckIn.Id) async throws {
        try await client
            .rpc(fn: .deleteCheckInAsModerator, params: CheckIn.DeleteAsAdminRequest(id: id))
            .execute()
    }

    func getSummaryByProfileId(id: Profile.Id) async throws -> Profile.Summary {
        try await client
            .rpc(fn: .getProfileSummary, params: ["p_uid": id.rawValue])
            .select()
            .limit(1)
            .single()
            .execute()
            .value
    }

    func uploadImage(id: CheckIn.Id, data: Data, userId: Profile.Id, blurHash: String?) async throws -> ImageEntity.Saved {
        let fileName = "\(id)_\(Int(Date().timeIntervalSince1970)).jpeg"
        let path = "\(userId.uuidString.lowercased())/\(fileName)"

        try await client
            .storage
            .from(.checkIns)
            .upload(path: path, file: data, options: .init(cacheControl: "max-age=3600", contentType: "image/jpeg"))

        if let blurHash {
            return try await updateImageBlurHash(file: path, blurHash: blurHash)
        } else {
            return try await imageEntityRepository.getByFileName(from: .checkInImages, fileName: path)
        }
    }

    func updateImageBlurHash(file: String, blurHash: String) async throws -> ImageEntity.Saved {
        try await client
            .rpc(fn: .updateCheckInImageBlurHash, params: UpdateCheckInImageBlurHashParams(file: file, blurHash: blurHash))
            .select(ImageEntity.getQuery(.saved(nil)))
            .single()
            .execute()
            .value
    }
}

struct UpdateCheckInImageBlurHashParams: Codable {
    let file: String
    let blurHash: String

    enum CodingKeys: String, CodingKey {
        case file = "p_file"
        case blurHash = "p_blur_hash"
    }
}

public enum CheckInImageQueryType: Sendable {
    case profile(Profile.Id)
    case product(Product.Id)

    var column: String {
        switch self {
        case .profile:
            "created_by"
        case .product:
            "check_ins.product_id"
        }
    }

    var id: String {
        switch self {
        case let .profile(id):
            id.uuidString
        case let .product(id):
            String(id)
        }
    }
}
