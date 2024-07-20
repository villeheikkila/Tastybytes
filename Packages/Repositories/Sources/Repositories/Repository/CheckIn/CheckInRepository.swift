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
    case afterId(CheckIn.Id)
}

public protocol CheckInRepository: Sendable {
    func getActivityFeed(query: ActivityFeedQueryType) async throws -> [CheckIn]
    func getById(id: CheckIn.Id) async throws -> CheckIn
    func getByProfileId(id: Profile.Id, queryType: CheckInQueryType) async throws -> [CheckIn]
    func getByProductId(id: Product.Id, segment: CheckInSegment, from: Int, to: Int) async throws -> [CheckIn]
    func getByLocation(locationId: Location.Id, segment: CheckInSegment, from: Int, to: Int) async throws -> [CheckIn]
    func getCheckInImages(id: Profile.Id, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func create(newCheckInParams: CheckIn.NewRequest) async throws -> CheckIn
    func update(updateCheckInParams: CheckIn.UpdateRequest) async throws -> CheckIn
    func delete(id: CheckIn.Id) async throws
    func deleteAsModerator(checkIn: CheckIn) async throws
    func getSummaryByProfileId(id: Profile.Id) async throws -> ProfileSummary
    func uploadImage(id: CheckIn.Id, data: Data, userId: Profile.Id, blurHash: String?) async throws -> ImageEntity
}
