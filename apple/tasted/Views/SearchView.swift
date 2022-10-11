import SwiftUI

struct SearchView: View {
    @State private var products = [Product]()

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(products) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.description)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Products")
        }
        .onSubmit(of: .search, runSearch)
    }

    func runSearch() {
        Task {
            products = try await API.supabase.database.rpc(fn: "fnc__search_products", params: SearchProductsParams(p_search_term: searchText))
                .select(columns: "id, name, description, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))").execute().decoded(to: [Product].self)
        }
    }
}

struct SearchProductsParams: Codable {
    let p_search_term: String
}

struct SubBrand {
    let name: String
}

struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let sub-brands: SubBrand
}
