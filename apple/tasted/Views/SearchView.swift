import SwiftUI

struct SearchView: View {
    @State private var products = [Product]()
    @StateObject private var model = SearchViewModel()
    @State private var searchText = ""

    var body: some View {
        // TODO: NavigationView should be removed
        NavigationView {
            List {
                ForEach(model.products, id: \.id) { product in
                    NavigationLink(value: product) {
                        ProductListItemView(product: product)
                    }
                }
            }
            .searchable(text: $model.searchText)
            .navigationTitle("Products")
            .onSubmit(of: .search, model.searchProducts)
        }
    }
}

struct ProductListItemView: View {
    let product: Product

    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(product.subcategories[0].categories.name).font(.system(size: 12, weight: .bold, design: .default))
            HStack {
                Text(product.subBrand.brands.name).font(.headline)
                    .font(.system(size: 18, weight: .bold, design: .default))

                if product.subBrand.name != "" {
                    Text(product.subBrand.name).font(.headline)
                        .font(.system(size: 18, weight: .bold, design: .default))
                }
                Text(product.name).font(.headline).font(.system(size: 18, weight: .bold, design: .default))
            }
            Text(product.subBrand.brands.companies.name).font(.system(size: 12, design: .default))
            HStack {
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name)
                }
            }.padding(.top, 5)
        }
    }
}

extension SearchView {
    class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Product]()

        struct SearchProductsParams: Codable {
            let p_search_term: String
        }

        func searchProducts() {
            let partialSearch = "%\(searchText)%"
            let productSearchQuery = API.supabase.database.rpc(fn: "fnc__search_products", params: SearchProductsParams(p_search_term: partialSearch))
                .select(columns: "id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))")
            Task {
                let searchResults = try await  productSearchQuery.execute().decoded(to: [Product].self)
                
                DispatchQueue.main.async {
                    self.products = searchResults
                }
            }
        }
    }
}
