import Foundation
import Models
import Supabase
import SupabaseStorage

protocol BrandRepository {
    func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error>
    func getJoinedById(id: Int) async -> Result<Brand.JoinedSubBrandsProductsCompany, Error>
    func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[Brand.JoinedSubBrands], Error>
    func getUnverified() async -> Result<[Brand.JoinedSubBrandsProductsCompany], Error>
    func getSummaryById(id: Int) async -> Result<Summary, Error>
    func insert(newBrand: Brand.NewRequest) async -> Result<Brand.JoinedSubBrands, Error>
    func isLikedByCurrentUser(id: Int) async -> Result<Bool, Error>
    func likeBrand(brandId: Int) async -> Result<Void, Error>
    func unlikeBrand(brandId: Int) async -> Result<Void, Error>
    func update(updateRequest: Brand.UpdateRequest) async -> Result<Void, Error>
    func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func uploadLogo(brandId: Int, data: Data) async -> Result<String, Error>
}

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient

    func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error> {
        do {
            let response: Brand.JoinedSubBrandsProducts = try await client
                .database
                .from(.brands)
                .select(columns: Brand.getQuery(.joined(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
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
                .select(columns: Brand.getQuery(.joinedSubBrandsCompany(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
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
                .select(columns: Brand.getQuery(.joinedSubBrandsCompany(false)))
                .eq(column: "is_verified", value: false)
                .order(column: "created_at", ascending: false)
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
                .select(columns: Brand.getQuery(.joinedSubBrands(false)))
                .eq(column: "brand_owner_id", value: brandOwnerId)
                .order(column: "name")
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
                .insert(values: newBrand, returning: .representation)
                .select(columns: Brand.getQuery(.joinedSubBrands(false)))
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
                .insert(values: BrandLike.New(brandId: brandId))
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
                .eq(column: "brand_id", value: brandId)
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

    func update(updateRequest: Brand.UpdateRequest) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.brands)
                .update(values: updateRequest)
                .eq(column: "id", value: updateRequest.id)
                .execute()

            return .success(())
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
                .eq(column: "id", value: id)
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
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func uploadLogo(brandId: Int, data: Data) async -> Result<String, Error> {
        do {
            let fileName = "\(brandId)_\(Date().customFormat(.fileNameSuffix)).jpeg"
            let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/jpeg")

            _ = try await client
                .storage
                .from(.logos)
                .upload(path: fileName, file: file, fileOptions: nil)

            return .success(fileName)
        } catch {
            return .failure(error)
        }
    }
}
