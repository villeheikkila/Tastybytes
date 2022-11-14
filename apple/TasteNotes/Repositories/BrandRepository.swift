import Foundation
import Supabase

protocol BrandRepository {
    func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[BrandJoinedWithSubBrands], Error>
    func insert(newBrand: NewBrand) async -> Result<BrandJoinedWithSubBrands, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient

    func getByBrandOwnerId(brandOwnerId: Int) async -> Result<[BrandJoinedWithSubBrands], Error> {
        do {
            let response = try await client
                .database
                .from(Brand.getQuery(.tableName))
                .select(columns: Brand.getQuery(.joinedSubBrands(false)))
                .eq(column: "brand_owner_id", value: brandOwnerId)
                .order(column: "name")
                .execute()
                .decoded(to: [BrandJoinedWithSubBrands].self)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newBrand: NewBrand) async -> Result<BrandJoinedWithSubBrands, Error> {
        do {
            let response = try await client
                .database
                .from(Brand.getQuery(.tableName))
                .insert(values: newBrand, returning: .representation)
                .select(columns: Brand.getQuery(.joinedSubBrands(false)))
                .single()
                .execute()
                .decoded(to: BrandJoinedWithSubBrands.self)

            return .success(response)
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
}
