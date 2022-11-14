import Foundation
import Supabase

protocol BrandRepository {
    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands]
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands
    func delete(id: Int) async throws -> Void
}

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient
    
    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands] {
        return try await client
            .database
            .from(Brand.getQuery(.tableName))
            .select(columns: Brand.getQuery(.joinedSubBrands(false)))
            .eq(column: "brand_owner_id", value: brandOwnerId)
            .order(column: "name")
            .execute()
            .decoded(to: [BrandJoinedWithSubBrands].self)
    }
    
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands {
        return try await client
            .database
            .from(Brand.getQuery(.tableName))
            .insert(values: newBrand, returning: .representation)
            .select(columns: Brand.getQuery(.joinedSubBrands(false)))
            .single()
            .execute()
            .decoded(to: BrandJoinedWithSubBrands.self)
    }
    
    func delete(id: Int) async throws -> Void {
        try await client
            .database
            .from(Brand.getQuery(.tableName))
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
}
