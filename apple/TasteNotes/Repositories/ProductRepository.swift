import Foundation
import Supabase

protocol ProductRepository {
  func search(searchTerm: String, categoryName: Category.Name?) async -> Result<[Product.Joined], Error>
  func search(barcode: Barcode) async -> Result<[Product.Joined], Error>
  func getById(id: Int) async -> Result<Product.Joined, Error>
  func delete(id: Int) async -> Result<Void, Error>
  func create(newProductParams: Product.NewRequest) async -> Result<Product.Joined, Error>
  func getSummaryById(id: Int) async -> Result<Summary, Error>
  func addBarcodeToProduct(product: Product.Joined, barcode: Barcode) async -> Result<Barcode, Error>
  func mergeProducts(productId: Int, toProductId: Int) async -> Result<Void, Error>
  func editProduct(productEditParams: Product.EditRequest) async -> Result<Void, Error>
  func createUpdateSuggestion(productEditSuggestionParams: Product.EditRequest) async -> Result<IntId, Error>
  func verifyProduct(productId: Int) async -> Result<Void, Error>
}

struct SupabaseProductRepository: ProductRepository {
  let client: SupabaseClient

  func search(searchTerm: String, categoryName: Category.Name?) async -> Result<[Product.Joined], Error> {
    do {
      let response: [Product.Joined] = try await client
        .database
        .rpc(
          fn: "fnc__search_products",
          params: Product.SearchParams(searchTerm: searchTerm, categoryName: categoryName)
        )
        .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func search(barcode: Barcode) async -> Result<[Product.Joined], Error> {
    do {
      let response: [ProductBarcode.Joined] = try await client
        .database
        .from(ProductBarcode.getQuery(.tableName))
        .select(columns: ProductBarcode.getQuery(.joined(false)))
        .eq(column: "barcode", value: barcode.barcode)
        .eq(column: "type", value: barcode.type.rawValue)
        .execute()
        .value

      return .success(response.map(\.product))
    } catch {
      return .failure(error)
    }
  }

  func getById(id: Int) async -> Result<Product.Joined, Error> {
    do {
      let response: Product.Joined = try await client
        .database
        .from(Product.getQuery(.tableName))
        .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
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

  func getByUserId(userId: Int) async -> Result<Product.Joined, Error> {
    do {
      let response: Product.Joined = try await client
        .database
        .from("product_user_ratings")
        .select(columns: Product.getQuery(.joinedBrandSubcategories(false)))
        .eq(column: "id", value: userId)
        .limit(count: 1)
        .single()
        .execute()
        .value

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
      let product: IntId = try await client
        .database
        .rpc(fn: "fnc__create_product", params: newProductParams)
        .select(columns: "id")
        .limit(count: 1)
        .single()
        .execute()
        .value
      /**
       TODO: Investigate if it is possible to somehow join sub_brands immediately after it has been created
       as part of the fnc__create_product function. 22.10.2022
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
      try await client
        .database
        .rpc(
          fn: "fnc__merge_products",
          params: Product.MergeProductsParams(productId: productId, toProductId: toProductId)
        )
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func createUpdateSuggestion(productEditSuggestionParams: Product.EditRequest) async -> Result<IntId, Error> {
    do {
      let productEditSuggestion: IntId = try await client
        .database
        .rpc(fn: "fnc__create_product_edit_suggestion", params: productEditSuggestionParams)
        .select(columns: "id")
        .limit(count: 1)
        .single()
        .execute()
        .value

      return .success(productEditSuggestion)
    } catch {
      return .failure(error)
    }
  }

  func editProduct(productEditParams: Product.EditRequest) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__edit_product", params: productEditParams)
        .execute()
        .value

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func verifyProduct(productId: Int) async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__verify_product", params: Product.VerifyRequest(id: productId))
        .single()
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
        .rpc(fn: "fnc__get_product_summary", params: Product.SummaryRequest(id: id))
        .select()
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
