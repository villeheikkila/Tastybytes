import Foundation
import Supabase

protocol LocationRepository {
    func insert(location: Location) async throws -> Result<Location, Error>
}

struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient
    private let tableName = "locations"
    private let saved = "id, name, title, longitude, latitude, country_code, countries (country_code, name, emoji)"
    
    func insert(location: Location) async throws -> Result<Location, Error> {
        do {
            let result =  try await client
                .database
                .from(tableName)
                .insert(values: location, returning: .representation)
                .select(columns: saved)
                .single()
                .execute()
                .decoded(to: Location.self)
            return .success(result)
        } catch {
           return .failure(error)
        }
    }
}
