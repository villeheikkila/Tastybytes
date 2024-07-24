import Models
internal import Supabase

struct SupabaseServingStyleRepository: ServingStyleRepository {
    let client: SupabaseClient

    func getAll() async throws -> [ServingStyle.Saved] {
        try await client
            .from(.servingStyles)
            .select(ServingStyle.getQuery(.saved(false)))
            .execute()
            .value
    }

    func insert(name: String) async throws -> ServingStyle.Saved {
        try await client
            .from(.servingStyles)
            .insert(["name": name], returning: .representation)
            .select(ServingStyle.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: ServingStyle.Id) async throws {
        try await client
            .from(.servingStyles)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func update(id: ServingStyle.Id, name: String) async throws -> ServingStyle.Saved {
        try await client
            .from(.servingStyles)
            .update(
                ["name": name],
                returning: .representation
            )
            .eq("id", value: id.rawValue)
            .select(ServingStyle.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }
}
