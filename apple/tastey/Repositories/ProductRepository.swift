import Foundation

struct SupabaseProductRepository {
    private let joined = "id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))"
    
    
    func search(searchTerm: String) async throws -> [Product] {
        struct SearchProductsParams: Codable {
            let p_search_term: String
            init(searchTerm: String) {
                self.p_search_term = "%\(searchTerm)%"
            }
        }
        
        return try await Supabase.client.database.rpc(fn: "fnc__search_products", params: SearchProductsParams(searchTerm: searchTerm))
            .select(columns: joined)
            .execute()
            .decoded(to: [Product].self)
    }
}
