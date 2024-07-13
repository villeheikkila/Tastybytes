import Foundation
import Models

public protocol LocationRepository: Sendable {
    func insert(location: Location) async throws -> Location
    func getById(id: UUID) async throws -> Location
    func getDetailed(id: UUID) async throws -> Location
    func delete(id: UUID) async throws
    func search(searchTerm: String) async throws -> [Location]
    func getCheckInLocations(userId: UUID) async throws -> [Location]
    func getSummaryById(id: UUID) async throws -> Summary
    func getSuggestions(location: Location.SuggestionParams) async throws -> [Location]
    func getRecentLocations(category: Location.RecentLocation) async throws -> [Location]
    func mergeLocations(locationId: UUID, toLocationId: UUID) async throws
    func getAllCountries() async throws -> [Country]
    func getLocations() async throws -> [Location]
    func update(request: Location.UpdateLocationRequest) async throws -> Location
}
