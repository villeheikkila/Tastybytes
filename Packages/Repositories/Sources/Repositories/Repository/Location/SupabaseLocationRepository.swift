import Foundation
import Models
import Supabase

struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient

    func insert(location: Location) async -> Result<Location, Error> {
        do {
            let result: Location = try await client
                .rpc(fn: .getLocationInsertIfNotExist, params: location.newLocationRequest)
                .select(Location.getQuery(.joined(false)))
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
                .from(.locations)
                .select(Location.getQuery(.joined(false)))
                .eq("id", value: id)
                .limit(1)
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
                .from(.viewRecentLocationsFromCurrentUser)
                .select(Location.getQuery(.joined(false)))
                .order("created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getRecentLocations(category: Location.RecentLocation) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .from(category.view)
                .select(Location.getQuery(.joined(false)))
                .limit(5)
                .order("created_at", ascending: false)
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
                .rpc(fn: .getLocationSuggestions, params: location)
                .select(Location.getQuery(.joined(false)))
                .limit(10)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getAllCountries() async -> Result<[Country], Error> {
        do {
            let response: [Country] = try await client
                .from(.countries)
                .select(Country.getQuery(.saved(false)))
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
                .from(.locations)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func search(searchTerm: String) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .from(.locations)
                .select(Location.getQuery(.joined(false)))
                .textSearch("name", query: searchTerm + ":*")
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
                .rpc(fn: .getLocationSummary, params: Location.SummaryRequest(id: id))
                .select()
                .limit(1)
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
