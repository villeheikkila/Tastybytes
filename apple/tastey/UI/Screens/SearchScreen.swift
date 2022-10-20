import SwiftUI

struct SearchScreenView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.products, id: \.self) { product in
                    NavigationLink(value: product) {
                        ProductListItemView(product: product)
                    }
                }
                if viewModel.isSearched {
                    Section {
                        NavigationLink("Add new", value: Route.addProduct)
                            .fontWeight(.medium)
                    } header: {
                        Text("Didn't find a product you were looking for?")
                    }
                    .textCase(nil)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Products")
            .onSubmit(of: .search, viewModel.searchProducts)
            .listStyle(InsetGroupedListStyle())
        }
    }
}

extension SearchScreenView {
    class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Product]()
        @Published var isSearched = false

        func searchProducts() {
            Task {
                let searchResults = try await repository.product.search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.products = searchResults
                    self.isSearched = true
                }
            }
        }
    }
}
