import Foundation
import Models
import Supabase

protocol LocationRepository {
    func insert(location: Location) async -> Result<Location, Error>
    func getById(id: UUID) async -> Result<Location, Error>
    func delete(id: UUID) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Location], Error>
    func getCheckInLocations(userId: UUID) async -> Result<[Location], Error>
    func getSummaryById(id: UUID) async -> Result<Summary, Error>
    func getSuggestions(location: Location.SuggestionParams) async -> Result<[Location], Error>
    func getRecentLocations() async -> Result<[Location], Error>
    func mergeLocations(locationId: UUID, toLocationId: UUID) async -> Result<Void, Error>
}

struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient

    func insert(location: Location) async -> Result<Location, Error> {
        do {
            let result: Location = try await client
                .database
                .rpc(fn: .getLocationInsertIfNotExist, params: location)
                .select(columns: Location.getQuery(.joined(false)))
                .single()
                .execute()
                .value

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func getById(id: UUID) async -> Result<Location, Error> {
        do {
            let response: Location = try await client
                .database
                .from(.locations)
                .select(columns: Location.getQuery(.joined(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getCheckInLocations(userId _: UUID) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .database
                // TODO: Create a proper view for this
                .from(.viewRecentLocationsFromCurrentUser)
                .select(columns: Location.getQuery(.joined(false)))
                .order(column: "created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getRecentLocations() async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .database
                .from(.viewRecentLocationsFromCurrentUser)
                .select(columns: Location.getQuery(.joined(false)))
                .limit(count: 5)
                .order(column: "created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSuggestions(location: Location.SuggestionParams) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .database
                .rpc(fn: .getLocationSuggestions, params: location)
                .select(columns: Location.getQuery(.joined(false)))
                .limit(count: 10)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: UUID) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.locations)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .database
                .from(.locations)
                .select(columns: Location.getQuery(.joined(false)))
                .textSearch(column: "name", query: searchTerm + ":*")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: UUID) async -> Result<Summary, Error> {
        do {
            let response: Summary = try await client
                .database
                .rpc(fn: .getLocationSummary, params: Location.SummaryRequest(id: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func mergeLocations(locationId: UUID, toLocationId: UUID) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(
                    fn: .mergeLocations,
                    params: Location.MergeLocationParams(locationId: locationId, toLocationId: toLocationId)
                )
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
