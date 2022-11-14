import Foundation
import PostgREST
import Supabase

protocol FlavorRepository {
    func getAll() async throws -> [Flavor]
}

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient
    
    func getAll() async throws -> [Flavor] {
        return try await client
            .database
            .from(Flavor.getQuery(.tableName))
            .select(columns: Flavor.getQuery(.saved(false)))
            .execute()
            .decoded(to: [Flavor].self)
    }
}



