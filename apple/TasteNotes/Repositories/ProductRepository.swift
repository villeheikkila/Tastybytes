import Foundation
import Supabase

protocol ProductRepository {
    func search(searchTerm: String, categoryName: Category.Name?) async -> Result<[Product.Joined], Error>
    func search(barcode: Barcode) async -> Result<[Product.Joined], Error>
    func getById(id: Int) async -> Result<Product.Joined, Error>
    func delete(id: Int) async -> Result<Void, Error>
    func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error>
    func getSummaryById(id: Int) async -> Result<ProductSummary, Error>
    func addBarcodeToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error>
    func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error>
    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async -> Result<DecodableId, Error>
}

struct SupabaseProductRepository: ProductRepository {
    let client: SupabaseClient

    func search(searchTerm: String, categoryName: Category.Name?) async -> Result<[Product.Joined], Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__search_products", params: Product.SearchParams(searchTerm: searchTerm, categoryName: categoryName))
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .execute()
                .decoded(to: [Product.Joined].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func search(barcode: Barcode) async -> Result<[Product.Joined], Error> {
        do {
            let response = try await client
                .database
                .from(ProductBarcode.getQuery(.tableName))
                .select(columns: ProductBarcode.getQuery(.joined(false)))
                .eq(column: "barcode", value: barcode.barcode)
                .eq(column: "type", value: barcode.type.rawValue)
                .execute()
                .decoded(to: [ProductBarcode.Joined].self)

            return .success(response.map { $0.product })
        } catch {
            return .failure(error)
        }
    }

    func getById(id: Int) async -> Result<Product.Joined, Error> {
        do {
            let response = try await client
                .database
                .from(Product.getQuery(.tableName))
                .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
                .eq(column: "id", value: id)
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: Product.Joined.self)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(Product.getQuery(.tableName))
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error> {
        do {
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
        
            switch await getById(id: product.id) {
            case let .success(response):
                return .success(response)
            case let .failure(error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
    
    func addBarcodeToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error> {
        do {
            try await client
                .database
                .from(ProductBarcode.getQuery(.tableName))
                .insert(values: ProductBarcode.NewRequest(product: product, barcode: barcode), returning: .representation)
                .execute()
            
            return .success(barcode)
        } catch {
            return .failure(error)
        }
    }
    
    func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__merge_products", params: Product.MergeProductsParams(productId: productId, toProductId: toProductId))
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func createUpdateSuggestion(productEditSuggestionParams: Product.EditSuggestionRequest) async -> Result<DecodableId, Error> {
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

    func getSummaryById(id: Int) async -> Result<ProductSummary, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__get_product_summary", params: Product.SummaryRequest(id: id))
                .select()
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: ProductSummary.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
