import Foundation
import Models

public enum CheckInQueryType {
    case paginated(Int, Int)
    case all
}

public protocol CheckInRepository {
    func getActivityFeed(from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getById(id: Int) async -> Result<CheckIn, Error>
    func getByProfileId(id: UUID, queryType: CheckInQueryType) async -> Result<[CheckIn], Error>
    func getByProductId(id: Int, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getByLocation(locationId: UUID, segment: CheckInSegment, from: Int, to: Int) async -> Result<[CheckIn], Error>
    func getCheckInImages(id: UUID, from: Int, to: Int) async -> Result<[CheckIn.Image], Error>
    func getCheckInImages(by: CheckInImageQueryType, from: Int, to: Int) async -> Result<[CheckIn.Image], Error>
    func create(newCheckInParams: CheckIn.NewRequest) async -> Result<CheckIn, Error>
    func update(updateCheckInParams: CheckIn.UpdateRequest) async -> Result<CheckIn, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func deleteAsModerator(checkIn: CheckIn) async -> Result<Void, Error>
    func getSummaryByProfileId(id: UUID) async -> Result<ProfileSummary, Error>
    func uploadImage(id: Int, data: Data, userId: UUID) async -> Result<String, Error>
}
