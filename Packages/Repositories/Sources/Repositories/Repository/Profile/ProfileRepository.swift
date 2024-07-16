import Foundation
import Models

public protocol ProfileRepository: Sendable {
    func getById(id: UUID) async throws -> Profile
    func getDetailed(id: UUID) async throws -> Profile.Detailed
    func getAll() async throws -> [Profile]
    func getCurrentUser() async throws -> Profile.Extended
    func update(update: Profile.UpdateRequest) async throws -> Profile.Extended
    func currentUserExport() async throws -> String
    func search(searchTerm: String, currentUserId: UUID?) async throws -> [Profile]
    func uploadAvatar(userId: UUID, data: Data) async throws -> ImageEntity
    func deleteCurrentAccount() async throws
    func updateSettings(update: ProfileSettings.UpdateRequest) async throws -> ProfileSettings
    func getContributions(id: UUID) async throws -> Profile.Contributions
    func getCategoryStatistics(userId: UUID) async throws -> [CategoryStatistics]
    func getSubcategoryStatistics(userId: UUID, categoryId: Int) async throws -> [SubcategoryStatistics]
    func getTimePeriodStatistics(userId: UUID, timePeriod: StatisticsTimePeriod) async throws -> TimePeriodStatistic
    func checkIfUsernameIsAvailable(username: String) async throws -> Bool
    func getNumberOfCheckInsByDay(_ request: NumberOfCheckInsByDayRequest) async throws -> [CheckInsPerDay]
    func getNumberOfCheckInsByLocation(userId: UUID) async throws -> [ProfileTopLocations]
    func deleteUserAsSuperAdmin(_ profile: Profile) async throws
}
