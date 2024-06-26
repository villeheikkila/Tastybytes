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
    func getActivityFeed(query: ActivityFeedQueryType) async -> Result<[CheckIn], Error>
    func getById(id: Int) async -> Result<CheckIn, Error>
    func getByProfileId(id: UUID, queryType: CheckInQueryType) async -> Result<[CheckIn], Error>
    func getByProductId(id: Int, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getByLocation(locationId: UUID, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getCheckInImages(id: UUID, from: Int, to: Int) async -> Result<[ImageEntity.JoinedCheckIn], Error>
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async -> Result<[ImageEntity.JoinedCheckIn], Error>
    func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error>
    func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func deleteAsModerator(checkIn: CheckIn) async -> Result<Void, Error>
    func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error>
    func uploadImage(id: Int, data: Data, userId: UUID, blurHash: String?) async -> Result<ImageEntity, Error>
}
