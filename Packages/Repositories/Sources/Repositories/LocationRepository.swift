import Foundation
import Models
import Supabase

public protocol LocationRepository {
    func insert(location: Location) async -> Result<Location, Error>
    func getById(id: UUID) async -> Result<Location, Error>
    func delete(id: UUID) async -> Result<Void, Error>
    func search(searchTerm: String) async -> Result<[Location], Error>
    func getCheckInLocations(userId: UUID) async -> Result<[Location], Error>
    func getSummaryById(id: UUID) async -> Result<Summary, Error>
    func getSuggestions(location: Location.SuggestionParams) async -> Result<[Location], Error>
    func getRecentLocations(category: Location.RecentLocation) async -> Result<[Location], Error>
    func mergeLocations(locationId: UUID, toLocationId: UUID) async -> Result<Void, Error>
}

public struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient

    public func insert(location: Location) async -> Result<Location, Error> {
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

    public func getById(id: UUID) async -> Result<Location, Error> {
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

    public func getCheckInLocations(userId _: UUID) async -> Result<[Location], Error> {
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

    public func getRecentLocations(category: Location.RecentLocation) async -> Result<[Location], Error> {
        do {
            let response: [Location] = try await client
                .database
                .from(category.view)
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

    public func getSuggestions(location: Location.SuggestionParams) async -> Result<[Location], Error> {
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

    public func delete(id: UUID) async -> Result<Void, Error> {
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

    public func search(searchTerm: String) async -> Result<[Location], Error> {
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

    public func getSummaryById(id: UUID) async -> Result<Summary, Error> {
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

    public func mergeLocations(locationId: UUID, toLocationId: UUID) async -> Result<Void, Error> {
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

public extension Country {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.countries.rawValue
        let saved = "country_code, name, emoji"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}

public extension Location {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.locations.rawValue
        let saved = "id, name, title, longitude, latitude, country_code"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, Country.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}
