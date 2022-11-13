import Foundation
import Supabase

protocol ProductRepository {
    func search(searchTerm: String) async throws -> [ProductJoined]
    func delete(id: Int) async throws -> Void
    func create(newProductParams: NewProductParams) async throws -> ProductJoined
    func getSummaryById(id: Int) async throws -> ProductSummary
    func createUpdateSuggestion(productEditSuggestionParams: NewProductEditSuggestionParams) async -> Result<DecodableId, Error> 
}

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient
    private let tableName = Product.getQuery(.tableName)
    private let joined = Product.getQuery(.joinedBrandSubcategories(false))
    
    
    func search(searchTerm: String) async throws -> [ProductJoined] {
        struct SearchProductsParams: Encodable {
            let p_search_term: String
            init(searchTerm: String) {
                self.p_search_term = "%\(searchTerm.trimmingCharacters(in: .whitespacesAndNewlines))%"
            }
        }
        
        return try await client
            .database
            .rpc(fn: "fnc__search_products", params: SearchProductsParams(searchTerm: searchTerm))
            .select(columns: joined)
            .execute()
            .decoded(to: [ProductJoined].self)
    }
    
    func getProductById(id: Int) async throws -> ProductJoined {
        return try await client
            .database
            .from("products")
            .select(columns: joined)
            .eq(column: "id", value: id)
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: ProductJoined.self)
    }
    
    func delete(id: Int) async throws -> Void {
        try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
    
    func create(newProductParams: NewProductParams) async throws -> ProductJoined {
        let product = try await client
            .database
            .rpc(fn: "fnc__create_product", params: newProductParams)
            .select(columns: "id")
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: DecodableId.self)
        /**
         TODO: Investigate if it is possible to somehow join sub_brands immediately after it has been created as part of the fnc__create_product function. 22.10.2022
         */
        return try await getProductById(id: product.id)
    }
    
    func createUpdateSuggestion(productEditSuggestionParams: NewProductEditSuggestionParams) async -> Result<DecodableId, Error> {
        do {
            let productEditSuggestion = try await client
                .database
                .rpc(fn: "fnc__create_product_edit_suggestion", params: productEditSuggestionParams)
                .select(columns: "id")
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: DecodableId.self)
            return .success(productEditSuggestion)
        } catch {
            return .failure(error)
        }
    }
    
    func getSummaryById(id: Int) async throws -> ProductSummary {
        return try await client
            .database
            .rpc(fn: "fnc__get_product_summary", params: GetProductSummaryParams(id: id))
            .select()
            .limit(count: 1)
            .single()
            .execute()
            .decoded(to: ProductSummary.self)
    }
}
