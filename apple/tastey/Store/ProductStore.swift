import Foundation
import UnidirectionalFlow

struct ProductState: Equatable {
    var products: [Product] = []
    var isLoading = false
}

enum ProductAction: Equatable {
    case search(query: String)
    case setResults(products: [Product])
}

struct ProductReducer: Reducer {
    func reduce(oldState: ProductState, with action: ProductAction) -> ProductState {
        var state = oldState
        
        switch action {
        case .search:
            state.isLoading = true
        case let .setResults(products):
            state.products = products
            state.isLoading = false
        }
        
        return state
    }
}

struct ProductMiddleware: Middleware {
    struct Dependencies {
        var search: (String) async throws -> [Product]
        
        static var production: Dependencies {
            .init { query in
                return try await SupabaseProductRepository().search(searchTerm: query)
            }
        }
    }

    let dependencies: Dependencies
    
    func process(state: ProductState, with action: ProductAction) async -> ProductAction? {
        switch action {
        case let .search(query):
            let results = try? await dependencies.search(query)
            return .setResults(products: results ?? [])
        default:
            return nil
        }
    }
}

typealias ProductStore = Store<ProductState, ProductAction>
