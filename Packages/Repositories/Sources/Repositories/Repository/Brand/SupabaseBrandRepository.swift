import Foundation
import Models
internal import Supabase

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Int) async throws -> Brand.JoinedSubBrandsProducts {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joined(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getJoinedById(id: Int) async throws -> Brand.JoinedSubBrandsProductsCompany {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func getDetailed(id: Int) async throws -> Brand.JoinedSubBrandsProductsCompany {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.detailed(false)))
            .eq("id", value: id)
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

    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [Brand.JoinedSubBrands] {
        try await client
            .from(.brands)
            .select(Brand.getQuery(.joinedSubBrands(false)))
            .eq("brand_owner_id", value: brandOwnerId)
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

    func isLikedByCurrentUser(id: Int) async throws -> Bool {
        try await client
            .rpc(
                fn: .isBrandLikedByCurrentUser,
                params: BrandLike.CheckIfLikedRequest(id: id)
            )
            .single()
            .execute()
            .value
    }

    func likeBrand(brandId: Int) async throws {
        try await client
            .from(.brandLikes)
            .insert(BrandLike.New(brandId: brandId))
            .single()
            .execute()
    }

    func unlikeBrand(brandId: Int) async throws {
        try await client
            .from(.brandLikes)
            .delete()
            .eq("brand_id", value: brandId)
            .execute()
    }

    func verification(id: Int, isVerified: Bool) async throws {
        try await client
            .rpc(fn: .verifyBrand, params: Brand.VerifyRequest(id: id, isVerified: isVerified))
            .single()
            .execute()
    }

    func update(updateRequest: Brand.UpdateRequest) async throws -> Brand.JoinedSubBrandsProductsCompany {
        try await client
            .from(.brands)
            .update(updateRequest)
            .eq("id", value: updateRequest.id)
            .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.brands)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func getSummaryById(id: Int) async throws -> Summary {
        try await client
            .from(.viewBrandRatings)
            .select()
            .eq("id", value: id)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func uploadLogo(brandId: Int, data: Data) async throws -> ImageEntity {
        let fileName = "\(brandId)_\(Date.now.timeIntervalSince1970).jpeg"

        try await client
            .storage
            .from(.brandLogos)
            .upload(path: fileName, file: data, options: .init(contentType: "image/jpeg"))

        return try await imageEntityRepository.getByFileName(from: .brandLogos, fileName: fileName)
    }
}
