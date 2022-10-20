import Foundation

protocol ProductRepository {
    func search(searchTerm: String) async throws -> [Product]
    func createProduct(newProductParams: NewProductParams) async throws -> Product
}

struct SupabaseProductRepository: ProductRepository {
    private let database = Supabase.client.database
    private let tableName = "companies"
    private let joined = "id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))"
    
    
    func search(searchTerm: String) async throws -> [Product] {
        struct SearchProductsParams: Encodable {
            let p_search_term: String
            init(searchTerm: String) {
                self.p_search_term = "%\(searchTerm)%"
            }
        }
        
        return try await database
            .rpc(fn: "fnc__search_products", params: SearchProductsParams(searchTerm: searchTerm))
            .select(columns: joined)
            .execute()
            .decoded(to: [Product].self)
    }
    
    func createProduct(newProductParams: NewProductParams) async throws -> Product {
        return try await database
            .rpc(fn: "fnc__create_product", params: newProductParams)
            .select(columns: joined)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: Product.self)
    }
}
