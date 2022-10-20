import Foundation
import PostgREST
import Supabase

protocol FlavorRepository {
    func getAll() async throws -> [Flavor]
}

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient
    private let tableName = "flavors"
    private let saved = "id, name"
    
    func getAll() async throws -> [Flavor] {
        return try await client
            .database
            .from(tableName)
            .select(columns: saved)
            .execute()
            .decoded(to: [Flavor].self)
    }
}
    


