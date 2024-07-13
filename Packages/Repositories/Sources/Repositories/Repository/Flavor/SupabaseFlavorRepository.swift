import Models
internal import Supabase

struct SupabaseFlavorRepository: FlavorRepository {
    let client: SupabaseClient

    func getAll() async throws -> [Flavor] {
        try await client
            .from(.flavors)
            .select(Flavor.getQuery(.saved(false)))
            .order("name")
            .execute()
            .value
    }

    func insert(newFlavor: Flavor.NewRequest) async throws -> Flavor {
        try await client
            .from(.flavors)
            .insert(newFlavor, returning: .representation)
            .select(Flavor.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.flavors)
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
