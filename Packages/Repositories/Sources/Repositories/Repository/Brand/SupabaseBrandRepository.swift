import Foundation
import Models
internal import Supabase

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Brand.Id) async throws -> Brand.JoinedSubBrandsProducts {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joined(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getJoinedById(id: Brand.Id) async throws -> Brand.JoinedSubBrandsProductsCompany {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getAll() async throws -> [Brand.JoinedCompany] {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedCompany(false)))
            .execute()
            .value
    }

    func getDetailed(id: Brand.Id) async throws -> Brand.Detailed {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.detailed(false)))
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getUnverified() async throws -> [Brand.JoinedSubBrandsProductsCompany] {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
            .eq("is_verified", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func getByBrandOwnerId(brandOwnerId: Company.Id) async throws -> [Brand.JoinedSubBrands] {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedSubBrands(false)))
            .eq("brand_owner_id", value: brandOwnerId.rawValue)
            .order("name")
            .execute()
            .value
    }

    func insert(newBrand: Brand.NewRequest) async throws -> Brand.JoinedSubBrands {
        try await client
            .from(.brands)
            .insert(newBrand, returning: .representation)
            .select(Brand.getQuery(.joinedSubBrands(false)))
            .single()
            .execute()
            .value
    }

    func isLikedByCurrentUser(id: Brand.Id) async throws -> Bool {
        try await client
            .rpc(
                fn: .isBrandLikedByCurrentUser,
                params: BrandLike.CheckIfLikedRequest(id: id)
            )
            .single()
            .execute()
            .value
    }

    func likeBrand(brandId: Brand.Id) async throws {
        try await client
            .from(.brandLikes)
            .insert(BrandLike.New(brandId: brandId))
            .single()
            .execute()
    }

    func unlikeBrand(brandId: Brand.Id) async throws {
        try await client
            .from(.brandLikes)
            .delete()
            .eq("brand_id", value: brandId.rawValue)
            .execute()
    }

    func verification(id: Brand.Id, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifyBrand, params: Brand.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func update(updateRequest: Brand.UpdateRequest) async throws -> Brand.Detailed {
        try await client
            .from(.brands)
            .update(updateRequest)
            .eq("id", value: updateRequest.id.rawValue)
            .select(Brand.getQuery(.detailed(false)))
            .single()
            .execute()
            .value
    }

    func editSuggestion(_ updateRequest: Brand.EditSuggestionRequest) async throws {
        try await client
            .from(.brandEditSuggestions)
            .insert(updateRequest)
            .execute()
    }

    func delete(id: Brand.Id) async throws {
        try await client
            .from(.brands)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func getSummaryById(id: Brand.Id) async throws -> Summary {
        try await client
            .from(.viewBrandRatings)
            .select()
            .eq("id", value: id.rawValue)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func uploadLogo(brandId: Brand.Id, data: Data) async throws -> ImageEntity {
        let fileName = "\(brandId)_\(Date.now.timeIntervalSince1970).jpeg"

        try await client
            .storage
            .from(.brandLogos)
            .upload(path: fileName, file: data, options: .init(contentType: "image/jpeg"))

        return try await imageEntityRepository.getByFileName(from: .brandLogos, fileName: fileName)
    }

    func resolveEditSuggestion(editSuggestion: Brand.EditSuggestion) async throws {
        try await client
            .from(.brandEditSuggestions)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func deleteEditSuggestion(editSuggestion: Brand.EditSuggestion) async throws {
        try await client
            .from(.brandEditSuggestions)
            .delete()
            .eq("id", value: editSuggestion.id.rawValue)
            .execute()
    }

    func getEditSuggestions() async throws -> [Models.Brand.EditSuggestion] {
        try await client
            .from(.brandEditSuggestions)
            .select(Brand.EditSuggestion.getQuery(.joined(false)))
            .execute()
            .value
    }
}
