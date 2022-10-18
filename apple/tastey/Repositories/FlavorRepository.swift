import Foundation
import PostgREST

struct SupabaseFlavorRepository {
    private let database = Supabase.client.database
    private let tableName = "flavors"
    private let saved = "id, name"
    
    func loadAll() async throws -> [Flavor] {
        return try await database
            .from(tableName)
            .select(columns: saved)
            .execute()
            .decoded(to: [Flavor].self)
    }
}
    


