import Foundation
import Models
import Supabase

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient
    let imageEntityRepository: ImageEntityRepository

    func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error> {
        do {
            let response: Brand.JoinedSubBrandsProducts = try await client
                .database
                .from(.brands)
                .select(Brand.getQuery(.joined(false)))
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getJoinedById(id: Int) async -> Result<Brand.JoinedSubBrandsProductsCompany, Error> {
        do {
            let response: Brand.JoinedSubBrandsProductsCompany = try await client
                .database
                .from(.brands)
                .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getUnverified() async -> Result<[Brand.JoinedSubBrandsProductsCompany], Error> {
        do {
            let response: [Brand.JoinedSubBrandsProductsCompany] = try await client
                .database
                .from(.brands)
                .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
                .eq("is_verified", value: false)
                .order("created_at", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[Brand.JoinedSubBrands], Error> {
        do {
            let response: [Brand.JoinedSubBrands] = try await client
                .database
                .from(.brands)
                .select(Brand.getQuery(.joinedSubBrands(false)))
                .eq("brand_owner_id", value: brandOwnerId)
                .order("name")
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newBrand: Brand.NewRequest) async -> Result<Brand.JoinedSubBrands, Error> {
        do {
            let response: Brand.JoinedSubBrands = try await client
                .database
                .from(.brands)
                .insert(newBrand, returning: .representation)
                .select(Brand.getQuery(.joinedSubBrands(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func isLikedByCurrentUser(id: Int) async -> Result<Bool, Error> {
        do {
            let response: Bool = try await client
                .database
                .rpc(
                    fn: .isBrandLikedByCurrentUser,
                    params: BrandLike.CheckIfLikedRequest(id: id)
                )
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func likeBrand(brandId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.brandLikes)
                .insert(BrandLike.New(brandId: brandId))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func unlikeBrand(brandId: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.brandLikes)
                .delete()
                .eq("brand_id", value: brandId)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .verifyBrand, params: Brand.VerifyRequest(id: id, isVerified: isVerified))
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func update(updateRequest: Brand.UpdateRequest) async -> Result<Brand.JoinedSubBrandsProductsCompany, Error> {
        do {
            let response: Brand.JoinedSubBrandsProductsCompany = try await client
                .database
                .from(.brands)
                .update(updateRequest)
                .eq("id", value: updateRequest.id)
                .select(Brand.getQuery(.joinedSubBrandsCompany(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.brands)
                .delete()
                .eq("id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getSummaryById(id: Int) async -> Result<Summary, Error> {
        do {
            let response: Summary = try await client
                .database
                .from(.viewBrandRatings)
                .select()
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadLogo(brandId: Int, data: Data) async -> Result<ImageEntity, Error> {
        do {
            let fileName = "\(brandId)_\(Date.now.timeIntervalSince1970).jpeg"
            let fileOptions = FileOptions(cacheControl: "604800", contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.brandLogos)
                .upload(path: fileName, file: data, options: fileOptions)

            return await imageEntityRepository.getByFileName(from: .brandLogos, fileName: fileName)
        } catch {
            return .failure(error)
        }
    }
}
