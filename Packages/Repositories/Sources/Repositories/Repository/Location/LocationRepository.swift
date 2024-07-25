import Foundation
import Models

public protocol LocationRepository: Sendable {
    func insert(location: Location.Saved) async throws -> Location.Saved
    func getById(id: Location.Id) async throws -> Location.Saved
    func getDetailed(id: Location.Id) async throws -> Location.Detailed
    func delete(id: Location.Id) async throws
    func search(searchTerm: String) async throws -> [Location.Saved]
    func getCheckInLocations(userId: Profile.Id) async throws -> [Location.Saved]
    func getSummaryById(id: Location.Id) async throws -> Summary
    func getSuggestions(location: Location.SuggestionParams) async throws -> [Location.Saved]
    func getRecentLocations(category: Location.RecentLocation) async throws -> [Location.Saved]
    func mergeLocations(id: Location.Id, toLocationId: Location.Id) async throws
    func getAllCountries() async throws -> [Country.Saved]
    func getLocations() async throws -> [Location.Saved]
    func update(request: Location.UpdateLocationRequest) async throws -> Location.Detailed
}
