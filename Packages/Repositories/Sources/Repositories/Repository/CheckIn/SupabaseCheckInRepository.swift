import Foundation
import Models
internal import Supabase

struct ActivityFeedParams: Encodable, Sendable {
    let pageSize: Int
    let cursor: CheckIn.Id?
    let filter: ActivityFeedFilter

    enum CodingKeys: String, CodingKey {
        case pageSize = "p_page_size"
        case cursor = "p_cursor"
        case filter = "p_filter"
    }
}

public enum ActivityFeedFilter: String, Encodable, Sendable {
    case both
    case friends
    case currentUser = "current_user"
}

struct SupabaseCheckInRepository: CheckInRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getActivityFeed(id: CheckIn.Id?, pageSize: Int, filter: ActivityFeedFilter) async throws -> [CheckIn.Joined] {
        try await client
            .rpc(
                fn: .activityFeed,
                params: ActivityFeedParams(pageSize: pageSize, cursor: id, filter: filter)
            )
            .select(CheckIn.getQuery(.joined(false)))
            .execute()
            .value
    }

    func getByProfileId(id: Profile.Id, queryType: CheckInQueryType) async throws -> [CheckIn.Joined] {
        try await client
            .rpc(
                fn: .getPaginatedCheckIns,
                params: queryType.getParams(createdBy: id)
            )
            .select(CheckIn.getQuery(.joined(false)))
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
            .select(ImageEntity.CheckInId.getQuery(.imageDetailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getCheckInImages(id: Profile.Id, from: Int, to: Int) async throws -> [ImageEntity.CheckInId] {
        try await client
            .from(.checkInImages)
            .select(ImageEntity.CheckInId.getQuery(.saved(false)))
            .eq("created_by", value: id.rawValue)
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.CheckInId] {
        try await client
            .from(.checkInImages)
            .select(ImageEntity.CheckInId.getQuery(.saved(false)))
            .eq(by.column, value: by.id)
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
    }

    func getProductCheckInImages(productId: Product.Id, from: Int, to: Int) async throws -> [ImageEntity.CheckInId] {
        try await client
            .from(.checkInImages)
            .select(ImageEntity.CheckInId.getQuery(.product(false)))
            .eq("check_ins.product_id", value: productId.rawValue)
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
            .rpc(fn: .deleteCheckInAsModerator, params: ["p_check_in_id": id.rawValue])
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

    func uploadImage(id: CheckIn.Id, data: Data, userId: Profile.Id, blurHash: String?, width: Int?, height: Int?) async throws -> ImageEntity.Saved {
        let fileName = "\(id)_\(Int(Date().timeIntervalSince1970)).jpeg"
        let path = "\(userId.uuidString.lowercased())/\(fileName)"
        let metadata = try? ["check_in_id": AnyJSON(id.rawValue), "width": AnyJSON(width), "height": AnyJSON(height), "blur_hash": AnyJSON(blurHash)]
        try await client
            .storage
            .from(.checkIns)
            .upload(
                path,
                data: data,
                options: .init(cacheControl: "max-age=3600", contentType: "image/jpeg", metadata: metadata)
            )
        return try await imageEntityRepository.getByFileName(from: .checkInImages, fileName: fileName)
    }
}

struct UpdateCheckInImageBlurHashParams: Codable {
    let file: String
    let blurHash: String?
    let width: Int?
    let height: Int?

    enum CodingKeys: String, CodingKey {
        case file = "p_file"
        case blurHash = "p_blur_hash"
        case width = "p_width"
        case height = "p_height"
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
