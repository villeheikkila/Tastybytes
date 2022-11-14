import Foundation
import Supabase

protocol LocationRepository {
    func insert(location: Location) async -> Result<Location, Error>
}

struct SupabaseLocationRepository: LocationRepository {
    let client: SupabaseClient

    func insert(location: Location) async -> Result<Location, Error> {
        do {
            let result =  try await client
                .database
                .from(Location.getQuery(.tableName))
                .insert(values: location, returning: .representation)
                .select(columns: Location.getQuery(.joined(false)))
                .single()
                .execute()
                .decoded(to: Location.self)
            return .success(result)
        } catch {
           return .failure(error)
        }
    }
}
