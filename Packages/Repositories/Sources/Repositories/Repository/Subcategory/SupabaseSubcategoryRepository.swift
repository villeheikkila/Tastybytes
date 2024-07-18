import Models
internal import Supabase

struct SupabaseSubcategoryRepository: SubcategoryRepository {
    let client: SupabaseClient

    func insert(newSubcategory: Subcategory.NewRequest) async throws -> Subcategory {
        try await client
            .from(.subcategories)
            .insert(newSubcategory, returning: .representation)
            .select(Subcategory.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Int) async throws -> Subcategory.Detailed {
        try await client
            .from(.subcategories)
            .select(Subcategory.getQuery(.detailed(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.subcategories)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func update(updateRequest: Subcategory.UpdateRequest) async throws {
        try await client
            .from(.subcategories)
            .update(updateRequest)
            .eq("id", value: updateRequest.id)
            .execute()
    }

    func verification(id: Int, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifySubcategory, params: Subcategory.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }
}
