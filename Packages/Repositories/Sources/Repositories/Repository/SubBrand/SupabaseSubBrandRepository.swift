import Models
internal import Supabase

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrand.NewRequest) async throws -> SubBrand {
        try await client
            .from(.subBrands)
            .insert(newSubBrand, returning: .representation)
            .select(SubBrand.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Int) async throws -> SubBrand.JoinedProduct {
        try await client
            .from(.subBrands)
            .select(SubBrand.getQuery(.detailed(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(updateRequest: SubBrand.Update) async throws -> SubBrand {
        let baseQuery = client
            .from(.subBrands)

        switch updateRequest {
        case let .brand(update):
            return try await baseQuery
                .update(update)
                .eq("id", value: update.id)
                .select(SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value
        case let .name(update):
            return try await baseQuery
                .update(update)
                .eq("id", value: update.id)
                .select(SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value
        }
    }

    func delete(id: Int) async throws {
        try await client
            .from(.subBrands)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func verification(id: Int, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifySubBrand, params: SubBrand.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func getUnverified() async throws -> [SubBrand.JoinedBrand] {
        try await client
            .from(.subBrands)
            .select(SubBrand.getQuery(.joinedBrand(false)))
            .eq("is_verified", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
