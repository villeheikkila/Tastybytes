import Foundation
import Models

struct GetPaginatedCheckInsParams: Codable {
    let lastSeenId: CheckIn.Id?
    let pageSize: Int
    let createdBy: Profile.Id
    let startDate: Date?
    let endDate: Date?
    let locationId: Location.Id?

    init(lastSeenId: CheckIn.Id? = nil, pageSize: Int, createdBy: Profile.Id, startDate: Date? = nil, endDate: Date? = nil, locationId: Location.Id? = nil) {
        self.lastSeenId = lastSeenId
        self.pageSize = pageSize
        self.createdBy = createdBy
        self.startDate = startDate
        self.endDate = endDate
        self.locationId = locationId
    }

    enum CodingKeys: String, CodingKey {
        case lastSeenId = "p_last_seen_id"
        case pageSize = "p_page_size"
        case createdBy = "p_created_by"
        case startDate = "p_start_date"
        case endDate = "p_end_date"
        case locationId = "p_location_id"
    }
}

public enum CheckInQueryType: Sendable {
    case paginated(_ lastCheckInId: CheckIn.Id?, _ pageSize: Int)
    case dateRange(_ lastCheckInId: CheckIn.Id?, _ pageSize: Int, ClosedRange<Date>)
    case location(_ lastCheckInId: CheckIn.Id?, _ pageSize: Int, Location.Id)
    case all

    func getParams(createdBy: Profile.Id) -> GetPaginatedCheckInsParams {
        switch self {
        case let .paginated(lastSeenId, pageSize):
            .init(
                lastSeenId: lastSeenId,
                pageSize: pageSize,
                createdBy: createdBy
            )

        case let .dateRange(lastSeenId, pageSize, dateRange):
            .init(
                lastSeenId: lastSeenId,
                pageSize: pageSize,
                createdBy: createdBy,
                startDate: dateRange.lowerBound,
                endDate: dateRange.upperBound
            )

        case let .location(lastSeenId, pageSize, id):
            .init(
                lastSeenId: lastSeenId,
                pageSize: pageSize,
                createdBy: createdBy,
                locationId: id
            )

        case .all:
            .init(
                lastSeenId: nil,
                pageSize: Int.max,
                createdBy: createdBy
            )
        }
    }
}

public protocol CheckInRepository: Sendable {
    func getActivityFeed(id: CheckIn.Id?, pageSize: Int) async throws -> [CheckIn.Joined]
    func getById(id: CheckIn.Id) async throws -> CheckIn.Joined
    func getDetailed(id: CheckIn.Id) async throws -> CheckIn.Detailed
    func getByProfileId(id: Profile.Id, queryType: CheckInQueryType) async throws -> [CheckIn.Joined]
    func getByProductId(id: Product.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined]
    func getByLocation(id: Location.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined]
    func getDetailedCheckInImage(id: ImageEntity.Id) async throws -> ImageEntity.Detailed
    func getCheckInImages(id: Profile.Id, from: Int, to: Int) async throws -> [ImageEntity.CheckInId]
    func getProductCheckInImages(productId: Product.Id, from: Int, to: Int) async throws -> [ImageEntity.CheckInId]
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.CheckInId]
    func create(newCheckInParams: CheckIn.NewRequest) async throws -> CheckIn.Joined
    func update(updateCheckInParams: CheckIn.UpdateRequest) async throws -> CheckIn.Joined
    func delete(id: CheckIn.Id) async throws
    func deleteAsModerator(id: CheckIn.Id) async throws
    func getSummaryByProfileId(id: Profile.Id) async throws -> Profile.Summary
    func uploadImage(id: CheckIn.Id, data: Data, userId: Profile.Id, blurHash: String?) async throws -> ImageEntity.Saved
}
