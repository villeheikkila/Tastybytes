import Foundation
import Models

public enum CheckInQueryType: Sendable {
    case paginated(Int, Int)
    case dateRange(Int, Int, ClosedRange<Date>)
    case location(Int, Int, Location.Saved)
    case all
}

public enum ActivityFeedQueryType: Sendable {
    case paginated(Int, Int)
    case afterId(CheckIn.Id)
}

public protocol CheckInRepository: Sendable {
    func getActivityFeed(query: ActivityFeedQueryType) async throws -> [CheckIn.Joined]
    func getById(id: CheckIn.Id) async throws -> CheckIn.Joined
    func getDetailed(id: CheckIn.Id) async throws -> CheckIn.Detailed
    func getByProfileId(id: Profile.Id, queryType: CheckInQueryType) async throws -> [CheckIn.Joined]
    func getByProductId(id: Product.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined]
    func getByLocation(id: Location.Id, segment: CheckIn.Segment, from: Int, to: Int) async throws -> [CheckIn.Joined]
    func getDetailedCheckInImage(id: ImageEntity.Id) async throws -> ImageEntity.Detailed
    func getCheckInImages(id: Profile.Id, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async throws -> [ImageEntity.JoinedCheckIn]
    func create(newCheckInParams: CheckIn.NewRequest) async throws -> CheckIn.Joined
    func update(updateCheckInParams: CheckIn.UpdateRequest) async throws -> CheckIn.Joined
    func delete(id: CheckIn.Id) async throws
    func deleteAsModerator(id: CheckIn.Id) async throws
    func getSummaryByProfileId(id: Profile.Id) async throws -> Profile.Summary
    func uploadImage(id: CheckIn.Id, data: Data, userId: Profile.Id, blurHash: String?) async throws -> ImageEntity.Saved
}
