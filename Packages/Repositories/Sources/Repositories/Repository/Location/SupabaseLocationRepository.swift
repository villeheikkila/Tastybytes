import Foundation
import Models
internal import Supabase

struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient

    func insert(location: Location.Saved) async throws -> Location.Saved {
        try await client
            .rpc(fn: .getLocationInsertIfNotExist, params: location.newLocationRequest)
            .select(Location.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }

    func getById(id: Location.Id) async throws -> Location.Saved {
        try await client
            .from(.locations)
            .select(Location.getQuery(.joined(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Location.Id) async throws -> Location.Detailed {
        try await client
            .from(.locations)
            .select(Location.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getCheckInLocations(userId _: Profile.Id) async throws -> [Location.Saved] {
        try await client
            .from(.viewRecentLocationsFromCurrentUser)
            .select(Location.getQuery(.joined(false)))
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func getRecentLocations(category: Location.RecentLocation) async throws -> [Location.Saved] {
        try await client
            .from(category.view)
            .select(Location.getQuery(.joined(false)))
            .limit(5)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func getSuggestions(location: Location.SuggestionParams) async throws -> [Location.Saved] {
        try await client
            .rpc(fn: .getLocationSuggestions, params: location)
            .select(Location.getQuery(.joined(false)))
            .limit(10)
            .execute()
            .value
    }

    func getAllCountries() async throws -> [Country.Saved] {
        try await client
            .from(.countries)
            .select(Country.getQuery(.saved(false)))
            .execute()
            .value
    }

    func delete(id: Location.Id) async throws {
        try await client
            .from(.locations)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func search(searchTerm: String) async throws -> [Location.Saved] {
        try await client
            .from(.locations)
            .select(Location.getQuery(.joined(false)))
            .textSearch("name", query: "'\(searchTerm)'")
            .execute()
            .value
    }

    func getSummaryById(id: Location.Id) async throws -> Summary {
        try await client
            .rpc(fn: .getLocationSummary, params: Location.SummaryRequest(id: id))
            .select()
            .limit(1)
            .single()
            .execute()
            .value
    }

    func mergeLocations(id: Location.Id, toLocationId: Location.Id) async throws {
        try await client
            .rpc(
                fn: .mergeLocations,
                params: Location.MergeLocationParams(locationId: id, toLocationId: toLocationId)
            )
            .execute()
    }

    func getLocations() async throws -> [Location.Saved] {
        try await client
            .from(.locations)
            .select(Location.getQuery(.detailed(false)))
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func update(request: Location.UpdateLocationRequest) async throws -> Location.Detailed {
        try await client
            .rpc(fn: .updateLocation, params: request)
            .select(Location.getQuery(.detailed(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }
}
