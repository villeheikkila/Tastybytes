import Foundation
import Supabase

protocol BrandRepository {
  func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error>
  func getJoinedById(id: Int) async -> Result<Brand.JoinedSubBrandsProductsCompany, Error>
  func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[Brand.JoinedSubBrands], Error>
  func getSummaryById(id: Int) async -> Result<Summary, Error>
  func insert(newBrand: Brand.NewRequest) async -> Result<Brand.JoinedSubBrands, Error>
  func update(updateRequest: Brand.UpdateRequest) async -> Result<Void, Error>
  func verification(id: Int, isVerified: Bool) async -> Result<Void, Error>
  func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseBrandRepository: BrandRepository {
  let client: SupabaseClient

  func getById(id: Int) async -> Result<Brand.JoinedSubBrandsProducts, Error> {
    do {
      let response: Brand.JoinedSubBrandsProducts = try await client
        .database
        .from(Brand.getQuery(.tableName))
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
        .from(Brand.getQuery(.tableName))
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

  func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[Brand.JoinedSubBrands], Error> {
    do {
      let response: [Brand.JoinedSubBrands] = try await client
        .database
        .from(Brand.getQuery(.tableName))
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
        .from(Brand.getQuery(.tableName))
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

  func verification(id: Int, isVerified: Bool) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__verify_brand", params: Brand.VerifyRequest(id: id, isVerified: isVerified))
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
        .from(Brand.getQuery(.tableName))
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
        .from(Brand.getQuery(.tableName))
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
        .from("view__brand_ratings")
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
}
