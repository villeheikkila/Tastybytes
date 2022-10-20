import Foundation
import Supabase

protocol BrandRepository {
    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands]
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands
}

struct SupabaseBrandRepository: BrandRepository {
    let client: SupabaseClient
    private let tableName = "brands"
    private let joinedWithSubBrands = "id, name, sub_brands (id, name)"
    
    
    func getByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands] {
        return try await client
            .database
            .from(tableName)
            .select(columns: joinedWithSubBrands)
            .eq(column: "brand_owner_id", value: brandOwnerId)
            .order(column: "name")
            .execute()
            .decoded(to: [BrandJoinedWithSubBrands].self)
    }
    
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands {
        return try await client
            .database
            .from(tableName)
            .insert(values: newBrand, returning: .representation)
            .select(columns: joinedWithSubBrands)
            .single()
            .execute()
            .decoded(to: BrandJoinedWithSubBrands.self)
    }
}
