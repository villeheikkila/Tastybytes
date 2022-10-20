import Foundation

protocol BrandRepository {
    func loadByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands]
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands
}

struct SupabaseBrandRepository: BrandRepository {
    private let database = Supabase.client.database
    private let tableName = "brands"
    private let joinedWithSubBrands = "id, name, sub_brands (id, name)"
    
    
    func loadByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands] {
        return try await database
            .from(tableName)
            .select(columns: joinedWithSubBrands)
            .eq(column: "brand_owner_id", value: brandOwnerId)
            .order(column: "name")
            .execute()
            .decoded(to: [BrandJoinedWithSubBrands].self)
    }
    
    func insert(newBrand: NewBrand) async throws -> BrandJoinedWithSubBrands {
        return try await database
            .from(tableName)
            .insert(values: newBrand, returning: .representation)
            .select(columns: joinedWithSubBrands)
            .single()
            .execute()
            .decoded(to: BrandJoinedWithSubBrands.self)
    }
}
