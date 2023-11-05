import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "MarkAsDuplicate")

struct DuplicateProductSheet: View {
    enum Mode {
        case mergeDuplicate, reportDuplicate
    }

    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var products = [Product.Joined]()
    @State private var showMergeToProductConfirmation = false
    @State private var searchTerm = ""
    @State private var alertError: AlertError?
    @State var searchTask: Task<Void, Never>?
    @State private var mergeToProduct: Product.Joined? {
        didSet {
            showMergeToProductConfirmation = true
        }
    }

    let mode: Mode
    let product: Product.Joined

    var body: some View {
        List {
            if products.isEmpty, mode == .reportDuplicate {
                Text("""
                Search for duplicate of \(product
                    .getDisplayName(
                        .fullName
                    )). Your request will be reviewed and products will be combined if appropriate.
                """).listRowSeparator(.hidden)
            }
            ForEach(products) { product in
                Button(action: { mergeToProduct = product }, label: {
                    ProductItemView(product: product)
                }).buttonStyle(.plain)
            }
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search for a duplicate product")
        .disableAutocorrection(true)
        .onSubmit(of: .search) {
            searchTask?.cancel()
            searchTask = Task { await searchProducts(name: searchTerm) }
        }
        .navigationTitle(mode == .mergeDuplicate ? "Merge duplicates" : "Mark as duplicate")
        .toolbar {
            toolbarContent
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchTerm, debounceTime: 0.2) { newValue in
            searchTask?.cancel()
            searchTask = Task { await searchProducts(name: newValue) }
        }
        .alertError($alertError)
        .confirmationDialog("Product Merge Confirmation",
                            isPresented: $showMergeToProductConfirmation,
                            presenting: mergeToProduct)
        { presenting in
            ProgressButton(
                """
                \(mode == .mergeDuplicate ? "Merge" : "Mark") \(product.name) \(
                    mode == .mergeDuplicate ? "to" : "as duplicate of") \(presenting.getDisplayName(.fullName))
                """,
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
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Close", role: .cancel, action: { dismiss() }).bold()
        }
    }

    func reportDuplicate(_ to: Product.Joined) async {
        switch await repository.product.markAsDuplicate(
            productId: product.id,
            duplicateOfProductId: to.id
        ) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await MainActor.run {
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger
                .error(
                    "reporting duplicate product \(product.id) of \(to.id) failed. error: \(error)"
                )
        }
    }

    func mergeProducts(_ to: Product.Joined) async {
        switch await repository.product.mergeProducts(productId: product.id, toProductId: to.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await MainActor.run {
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger
                .error("Merging product \(product.id) to \(to.id) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProducts(name: String) async {
        guard name.count > 1 else { return }
        switch await repository.product.search(searchTerm: name, filter: nil) {
        case let .success(searchResults):
            products = searchResults.filter { $0.id != product.id }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
