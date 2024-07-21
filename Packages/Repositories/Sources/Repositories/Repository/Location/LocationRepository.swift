import Foundation
import Models

public protocol LocationRepository: Sendable {
    func insert(location: Location) async throws -> Location
    func getById(id: Location.Id) async throws -> Location
    func getDetailed(id: Location.Id) async throws -> Location.Detailed
    func delete(id: Location.Id) async throws
    func search(searchTerm: String) async throws -> [Location]
    func getCheckInLocations(userId: Profile.Id) async throws -> [Location]
    func getSummaryById(id: Location.Id) async throws -> Summary
    func getSuggestions(location: Location.SuggestionParams) async throws -> [Location]
    func getRecentLocations(category: Location.RecentLocation) async throws -> [Location]
    func mergeLocations(locationId: Location.Id, toLocationId: Location.Id) async throws
    func getAllCountries() async throws -> [Country]
    func getLocations() async throws -> [Location]
    func update(request: Location.UpdateLocationRequest) async throws -> Location.Detailed
}
