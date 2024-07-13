import Foundation
import Models

public enum CheckInQueryType: Sendable {
    case paginated(Int, Int)
    case dateRange(Int, Int, ClosedRange<Date>)
    case location(Int, Int, Location)
    case all
}

public enum ActivityFeedQueryType: Sendable {
    case paginated(Int, Int)
    case afterId(Int)
}

public protocol CheckInRepository: Sendable {
    func getActivityFeed(query: ActivityFeedQueryType) async throws -> [CheckIn]
    func getById(id: Int) async throws -> CheckIn
    func getByProfileId(id: UUID, queryType: CheckInQueryType) async throws -> [CheckIn]
    func getByProductId(id: Int, segment: CheckInSegment, from: Int, to: Int) async throws -> [CheckIn]
    func getByLocation(locationId: UUID, segment: CheckInSegment, from: Int, to: Int) async throws -> [CheckIn]
    func getCheckInImages(id: UUID, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func create(newCheckInParams: CheckIn.NewRequest) async throws -> CheckIn
    func update(updateCheckInParams: CheckIn.UpdateRequest) async throws -> CheckIn
    func delete(id: Int) async throws
    func deleteAsModerator(checkIn: CheckIn) async throws
    func getSummaryByProfileId(id: UUID) async throws -> ProfileSummary
    func uploadImage(id: Int, data: Data, userId: UUID, blurHash: String?) async throws -> ImageEntity
}
