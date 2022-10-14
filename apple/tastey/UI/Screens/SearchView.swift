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

extension SearchView {
    class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Product]()

        func searchProducts() {
            Task {
                let searchResults = try await SupabaseProductRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.products = searchResults
                }
            }
        }
    }
}
