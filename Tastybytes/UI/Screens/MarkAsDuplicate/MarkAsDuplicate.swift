import SwiftUI

struct MarkAsDuplicate: View {
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var hapticManager: HapticManager
    @Environment(\.dismiss) private var dismiss

    init(_ client: Client, mode: Mode, product: Product.Joined) {
        _viewModel = StateObject(wrappedValue: ViewModel(client, mode: mode, product: product))
    }

    var body: some View {
        List {
            if viewModel.products.isEmpty, viewModel.mode == .reportDuplicate {
                Text(
                    """
                    Search for duplicate of \(viewModel.product.getDisplayName(.fullName)). \
                    Your request will be reviewed and products will be combined if appropriate.
                    """
                ).listRowSeparator(.hidden)
            }
            ForEach(viewModel.products, id: \.id) { product in
                Button(action: { viewModel.mergeToProduct = product }, label: {
                    ProductItemView(product: product)
                })
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search for a duplicate product")
        .disableAutocorrection(true)
        .onSubmit(of: .search) {
            viewModel.searchProducts()
        }
        .onReceive(
            viewModel.$searchTerm.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
        ) { _ in
            viewModel.searchProducts()
        }
        .confirmationDialog("Product Merge Confirmation",
                            isPresented: $viewModel.showMergeToProductConfirmation,
                            presenting: viewModel.mergeToProduct)
        { presenting in
            Button("Merge \(presenting.name) to \(presenting.getDisplayName(.fullName))", role: .destructive) {
                viewModel.markAsDuplicate(onSuccess: {
                    hapticManager.trigger(of: .notification(.success))
                    dismiss()
                })
            }
        }
    }
}

extension MarkAsDuplicate {
    enum Mode {
        case mergeDuplicate, reportDuplicate
    }

    @MainActor
    class ViewModel: ObservableObject {
        private let logger = getLogger(category: "MarkAsDuplicate")
        let client: Client
        @Published var products = [Product.Joined]()
        @Published var mergeToProduct: Product.Joined? {
            didSet {
                showMergeToProductConfirmation = true
            }
        }

        @Published var showMergeToProductConfirmation = false
        let mode: Mode

        @Published var searchTerm = ""
        let product: Product.Joined

        init(_ client: Client, mode: Mode, product: Product.Joined) {
            self.client = client
            self.mode = mode
            self.product = product
        }

        func markAsDuplicate(onSuccess _: @escaping () -> Void) {}

        func mergeProducts(productToMerge: Product.JoinedCategory, onSuccess: @escaping () -> Void) {
            if let mergeToProduct {
                Task {
                    switch await client.product.mergeProducts(productId: productToMerge.id, toProductId: mergeToProduct.id) {
                    case .success:
                        self.mergeToProduct = nil
                        onSuccess()
                    case let .failure(error):
                        logger
                            .error(
                                "merging product \(productToMerge.id) to \(mergeToProduct.id) failed: \(error.localizedDescription)"
                            )
                    }
                }
            }
        }

        func searchProducts() {
            Task {
                switch await client.product.search(searchTerm: searchTerm, filter: nil) {
                case let .success(searchResults):
                    self.products = searchResults
                case let .failure(error):
                    logger
                        .error(
                            """
                              "searching products with \(self.searchTerm)\
                              failed: \(error.localizedDescription)
                            """
                        )
                }
            }
        }
    }
}
