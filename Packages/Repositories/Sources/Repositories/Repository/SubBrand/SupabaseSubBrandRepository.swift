import Models
internal import Supabase

struct SupabaseSubBrandRepository: SubBrandRepository {
    let client: SupabaseClient

    func insert(newSubBrand: SubBrand.NewRequest) async throws -> SubBrand.Saved {
        try await client
            .from(.subBrands)
            .insert(newSubBrand, returning: .representation)
            .select(SubBrand.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func getDetailed(id: SubBrand.Id) async throws -> SubBrand.Detailed {
        try await client
            .from(.subBrands)
            .select(SubBrand.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func update(updateRequest: SubBrand.Update) async throws -> SubBrand.Saved {
        let baseQuery = client
            .from(.subBrands)

        switch updateRequest {
        case let .brand(update):
            return try await baseQuery
                .update(update)
                .eq("id", value: update.id.rawValue)
                .select(SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value
        case let .name(update):
            return try await baseQuery
                .update(update)
                .eq("id", value: update.id.rawValue)
                .select(SubBrand.getQuery(.saved(false)))
                .single()
                .execute()
                .value
        }
    }

    func delete(id: SubBrand.Id) async throws {
        try await client
            .from(.subBrands)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func verification(id: SubBrand.Id, isVerified: Bool) async throws {
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

    func deleteEditSuggestion(editSuggestion: SubBrand.EditSuggestion) async throws {
        try await client
            .from(.subBrandEditSuggestion)
            .delete()
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func createEditSuggestion(id: SubBrand.Id, brand: BrandProtocol?, name: String?, includesBrandName: Bool?) async throws {
        struct SubBrandEditSuggestionRequest: Encodable {
            let subBrandId: SubBrand.Id
            let includesBrandName: Bool?
            let name: String?
            let brandId: Brand.Id?

            init(id: SubBrand.Id, brand: BrandProtocol?, name: String?, includesBrandName: Bool?) {
                subBrandId = id
                self.includesBrandName = includesBrandName
                self.name = name
                brandId = brand?.id
            }

            enum CodingKeys: String, CodingKey {
                case subBrandId = "sub_brand_id"
                case includesBrandName = "includes_brand_name"
                case name
                case brandId = "brand_id"
            }
        }

        try await client
            .from(.subBrandEditSuggestion)
            .insert(
                SubBrandEditSuggestionRequest(
                    id: id,
                    brand: brand,
                    name: name,
                    includesBrandName: includesBrandName
                )
            )
            .execute()
            .value
    }

    func getEditSuggestions() async throws -> [SubBrand.EditSuggestion] {
        try await client
            .from(.subBrandEditSuggestion)
            .select(SubBrand.EditSuggestion.getQuery(.joined(false)))
            .execute()
            .value
    }
}
