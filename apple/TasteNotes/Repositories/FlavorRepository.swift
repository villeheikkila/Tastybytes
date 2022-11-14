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
            let response = try await client
                .database
                .from(Flavor.getQuery(.tableName))
                .select(columns: Flavor.getQuery(.saved(false)))
                .execute()
                .decoded(to: [Flavor].self)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
