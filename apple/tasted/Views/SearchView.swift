import SwiftUI

struct SearchView: View {
    @State private var products = [ProductResponse]()
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
    let product: ProductResponse

    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(product.subcategories[0].categories.name).font(.system(size: 12, weight: .bold, design: .default))
            HStack {
                Text(product.sub_brands.brands.name).font(.headline)
                    .font(.system(size: 18, weight: .bold, design: .default))

                if product.sub_brands.name != "" {
                    Text(product.sub_brands.name).font(.headline)
                        .font(.system(size: 18, weight: .bold, design: .default))
                }
                Text(product.name).font(.headline).font(.system(size: 18, weight: .bold, design: .default))
            }
            Text(product.sub_brands.brands.companies.name).font(.system(size: 12, design: .default))
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
        @Published var products = [ProductResponse]()

        struct SearchProductsParams: Codable {
            let p_search_term: String
        }

        func searchProducts() {
            Task {
                let response = try await API.supabase.database.rpc(fn: "fnc__search_products", params: SearchProductsParams(p_search_term: searchText))
                    .select(columns: "id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))").execute()

                let result = try response.decoded(to: [ProductResponse].self)

                DispatchQueue.main.async {
                    self.products = result
                }
            }
        }
    }
}
