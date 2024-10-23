import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ProductPickerSheet: View {
    private let logger = Logger(label: "ProductPickerSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var products = [Product.Joined]()
    @State private var searchTerm = ""
    @Binding var product: Product.Joined?

    var body: some View {
        List(products) { product in
            Button(action: {
                self.product = product
                dismiss()
            }) {
                ProductView(product: product)
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .animation(.default, value: products)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "product.picker.search.prompt")
        .disableAutocorrection(true)
        .navigationTitle("product.picker.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDismissAction()
        }
        .task(id: searchTerm, milliseconds: 200) {
            await search(searchTerm: searchTerm)
        }
    }

    private func search(searchTerm: String) async {
        guard searchTerm.count > 1 else { return }
        do {
            let searchResults = try await repository.product.search(searchTerm: searchTerm, filter: nil)
            products = searchResults.filter { $0.id != product?.id }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
