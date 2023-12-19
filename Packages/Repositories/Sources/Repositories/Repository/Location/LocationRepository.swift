import Foundation
import Models

public protocol LocationRepository: Sendable {
    func insert(location: Location) async -> Result<Location, Error>
    func getById(id: UUID) async -> Result<Location, Error>
    func delete(id: UUID) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Location], Error>
    func getCheckInLocations(userId: UUID) async -> Result<[Location], Error>
    func getSummaryById(id: UUID) async -> Result<Summary, Error>
    func getSuggestions(location: Location.SuggestionParams) async -> Result<[Location], Error>
    func getRecentLocations(category: Location.RecentLocation) async -> Result<[Location], Error>
    func mergeLocations(locationId: UUID, toLocationId: UUID) async -> Result<Void, Error>
    func getAllCountries() async -> Result<[Country], Error>
}
