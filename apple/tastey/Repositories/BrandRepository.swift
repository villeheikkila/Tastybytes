import Foundation

struct SupabaseBrandRepository {
    private let database = Supabase.client.database
    private let categories = "brands"
    private let joinedWithSubBrands = "id, name, sub_brands (id, name)"
    
    
    func loadByBrandOwnerId(brandOwnerId: Int) async throws -> [BrandJoinedWithSubBrands] {
        return try await database
            .from(categories)
            .select(columns: joinedWithSubBrands)
            .eq(column: "brand_owner_id", value: brandOwnerId)
            .order(column: "name")
            .execute()
            .decoded(to: [BrandJoinedWithSubBrands].self)
    }
}
