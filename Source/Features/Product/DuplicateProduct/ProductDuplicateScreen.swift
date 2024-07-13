import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductDuplicateScreen: View {
    private let logger = Logger(category: "ProductDuplicateScreen")
    enum Mode {
        case mergeDuplicate, reportDuplicate
    }

    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var products = [Product.Joined]()
    @State private var searchTerm = ""

    let mode: Mode
    let product: Product.Joined

    var body: some View {
        List(products) { product in
            DuplicateProductSheetRow(product: product, mode: mode) { product in
                switch mode {
                case .reportDuplicate:
                    await reportDuplicate(product)
                case .mergeDuplicate:
                    await mergeProducts(product)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if products.isEmpty, mode != .reportDuplicate {
                DuplicateProductContentUnavailableView(productName: product.formatted(.fullName))
            }
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "duplicateProduct.search.prompt")
        .disableAutocorrection(true)
        .navigationTitle(mode == .mergeDuplicate ? "duplicateProduct.mergeDuplicates.navigationTitle" : "duplicateProduct.markAsDuplicate.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 200) {
            await search(searchTerm: searchTerm)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func reportDuplicate(_ to: Product.Joined) async {
        do {
            try await repository.product.markAsDuplicate(productId: product.id, duplicateOfProductId: to.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("reporting duplicate product \(product.id) of \(to.id) failed. error: \(error)")
        }
    }

    private func mergeProducts(_ to: Product.Joined) async {
        do {
            try await repository.product.mergeProducts(productId: product.id, toProductId: to.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Merging product \(product.id) to \(to.id) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func search(searchTerm: String) async {
        guard searchTerm.count > 1 else { return }
        do {
            let searchResults = try await repository.product.search(searchTerm: searchTerm, filter: nil)
            products = searchResults.filter { $0.id != product.id }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
