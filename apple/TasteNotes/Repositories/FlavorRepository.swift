import Foundation
import PostgREST
import Supabase

protocol FlavorRepository {
    func getAll() async -> Result<[Flavor], Error>
}

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[Flavor], Error> {
        do {
            let response: [Flavor] = try await client
                .database
                .from(Flavor.getQuery(.tableName))
                .select(columns: Flavor.getQuery(.saved(false)))
                .order(column: "name")
                .execute()
                .value
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
