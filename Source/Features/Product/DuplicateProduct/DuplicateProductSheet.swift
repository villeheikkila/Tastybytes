import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DuplicateProductSheet: View {
    private let logger = Logger(category: "DuplicateProductSheet")
    enum Mode {
        case mergeDuplicate, reportDuplicate
    }

    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var products = [Product.Joined]()
    @State private var searchTerm = ""
    @State private var alertError: AlertError?
    @State private var mergeToProduct: Product.Joined?

    let mode: Mode
    let product: Product.Joined

    var body: some View {
        List(products) { product in
            DuplicateProductSheetRow(product: product) { product in
                mergeToProduct = product
            }
        }
        .listStyle(.plain)
        .background {
            if products.isEmpty, mode != .reportDuplicate {
                DuplicateProductContentUnavailableView(productName: product.formatted(.fullName))
            }
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "duplicateProduct.search.prompt")
        .disableAutocorrection(true)
        .navigationTitle(mode == .mergeDuplicate ? "duplicateProduct.mergeDuplicates.navigationTitle" : "duplicateProduct.markAsDuplicate.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 200) {
            await searchProducts(name: searchTerm)
        }
        .onAppear {
            // Change the .searchable cancel button tint
            UISearchBar.appearance().tintColor = UIColor(Color.primary)
        }
        .alertError($alertError)
        .confirmationDialog("duplicateProduct.mergeTo.description",
                            isPresented: $mergeToProduct.isNotNull(),
                            presenting: mergeToProduct)
        { presenting in
            ProgressButton(
                mode == .mergeDuplicate ? "duplicateProduct.mergeDuplicates.label \(product.name) \(presenting.formatted(.fullName))" : "duplicateProduct.markAsDuplicate.label \(product.name) \(presenting.formatted(.fullName))",
                role: .destructive
            ) {
                switch mode {
                case .reportDuplicate:
                    await reportDuplicate(presenting)
                case .mergeDuplicate:
                    await mergeProducts(presenting)
                }
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func reportDuplicate(_ to: Product.Joined) async {
        switch await repository.product.markAsDuplicate(
            productId: product.id,
            duplicateOfProductId: to.id
        ) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("reporting duplicate product \(product.id) of \(to.id) failed. error: \(error)")
        }
    }

    func mergeProducts(_ to: Product.Joined) async {
        switch await repository.product.mergeProducts(productId: product.id, toProductId: to.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Merging product \(product.id) to \(to.id) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProducts(name: String) async {
        guard name.count > 1 else { return }
        switch await repository.product.search(searchTerm: name, filter: nil) {
        case let .success(searchResults):
            products = searchResults.filter { $0.id != product.id }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
