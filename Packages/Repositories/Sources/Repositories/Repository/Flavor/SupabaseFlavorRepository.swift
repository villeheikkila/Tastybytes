import Models
internal import Supabase

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient

    func getAll() async throws -> [Flavor.Saved] {
        try await client
            .from(.flavors)
            .select(Flavor.getQuery(.saved(false)))
            .order("name")
            .execute()
            .value
    }

    func insert(name: String) async throws -> Flavor.Saved {
        try await client
            .from(.flavors)
            .insert(["name": name], returning: .representation)
            .select(Flavor.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Flavor.Id) async throws {
        try await client
            .from(.flavors)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }
}
