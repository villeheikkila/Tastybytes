import SwiftUI

struct SearchScreenView: View {
    @State private var products = [Product]()
    @StateObject private var model = SearchViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(model.products, id: \.self) { product in
                    NavigationLink(value: product) {
                        ProductListItemView(product: product)
                    }
                }
                if (model.isSearched) {
                    Section {
                        NavigationLink("Add new", value: Route.addProduct).fontWeight(.medium)
                    } header: {
                        Text("Didn't find a product you were looking for?")
                    }.textCase(nil)
                }
            }
            .searchable(text: $model.searchText)
            .navigationTitle("Products")
            .onSubmit(of: .search, model.searchProducts)
            .listStyle(InsetGroupedListStyle())
        }
    }
}

extension SearchScreenView {
    class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Product]()
        @Published var isSearched = false
        
        func searchProducts() {
            Task {
                let searchResults = try await SupabaseProductRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.products = searchResults
                    self.isSearched = true
                }
            }
        }
    }
}
