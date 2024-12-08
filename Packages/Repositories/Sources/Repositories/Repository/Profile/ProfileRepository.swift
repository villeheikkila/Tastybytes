import Foundation
import Models

public protocol ProfileRepository: Sendable {
    func getById(id: Profile.Id) async throws -> Profile.Saved
    func getDetailed(id: Profile.Id) async throws -> Profile.Detailed
    func getAll() async throws -> [Profile.Saved]
    func getCurrentUser() async throws -> Profile.Extended
    func update(update: Profile.UpdateRequest) async throws -> Profile.Extended
    func currentUserExport() async throws -> String
    func search(searchTerm: String, currentUserId: Profile.Id?) async throws -> [Profile.Saved]
    func uploadAvatar(id: Profile.Id, data: Data, width: Int, height: Int, blurHash: String?) async throws -> ImageEntity.Saved
    func deleteCurrentAccount() async throws
    func updateSettings(update: Profile.SettingsUpdateRequest) async throws -> Profile.Settings
    func getContributions(id: Profile.Id) async throws -> Profile.Contributions
    func getCategoryStatistics(id: Profile.Id) async throws -> [Profile.CategoryStatistics]
    func getSubcategoryStatistics(id: Profile.Id, categoryId: Models.Category.Id) async throws -> [Profile.SubcategoryStatistics]
    func getTimePeriodStatistics(id: Profile.Id, timePeriod: StatisticsTimePeriod) async throws -> Profile.TimePeriodStatistic
    func checkIfUsernameIsAvailable(username: String) async throws -> Bool
    func getNumberOfCheckInsByDay(_ request: NumberOfCheckInsByDayRequest) async throws -> [Profile.CheckInsPerDay]
    func getNumberOfCheckInsByLocation(id: Profile.Id) async throws -> [Profile.TopLocations]
    func deleteUserAsSuperAdmin(_ id: Profile.Id) async throws
}
