import Models
internal import Supabase

struct SupabaseServingStyleRepository: ServingStyleRepository {
    let client: SupabaseClient

    func getAll() async throws -> [ServingStyle] {
        try await client
            .from(.servingStyles)
            .select(ServingStyle.getQuery(.saved(false)))
            .execute()
            .value
    }

    func insert(servingStyle: ServingStyle.NewRequest) async throws -> ServingStyle {
        try await client
            .from(.servingStyles)
            .insert(servingStyle, returning: .representation)
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

    func update(update: ServingStyle.UpdateRequest) async throws -> ServingStyle {
        try await client
            .from(.servingStyles)
            .update(
                update,
                returning: .representation
            )
            .select(ServingStyle.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }
}
