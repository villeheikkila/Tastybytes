import SwiftUI

struct DuplicateProductSheet: View {
  enum Mode {
    case mergeDuplicate, reportDuplicate
  }

  private let logger = getLogger(category: "MarkAsDuplicate")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var products = [Product.Joined]()
  @State private var currentUserProductDuplicateSuggestions = [ProductDuplicateSuggestion]()
  @State private var mergeToProduct: Product.Joined? {
    didSet {
      showMergeToProductConfirmation = true
    }
  }

  @State private var showMergeToProductConfirmation = false
  @State private var searchTerm = ""

  let mode: Mode
  let product: Product.Joined

  var body: some View {
    List {
      if products.isEmpty, mode == .reportDuplicate {
        Text("""
        Search for duplicate of \(product
          .getDisplayName(.fullName)). Your request will be reviewed and products will be combined if appropriate.
        """).listRowSeparator(.hidden)
      }
      ForEach(products.filter { $0.id != product.id }) { product in
        Button(action: { mergeToProduct = product }, label: {
          ProductItemView(product: product)
        })
      }
    }
    .listStyle(.plain)
    .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a duplicate product")
    .disableAutocorrection(true)
    .onSubmit(of: .search) {
      Task { await searchProducts(name: searchTerm) }
    }
    .navigationTitle(mode == .mergeDuplicate ? "Merge duplicates" : "Mark a duplicate")
    .navigationBarItems(leading: Button("Close", role: .cancel, action: { dismiss() }).bold())
    .onChange(of: searchTerm, debounceTime: 0.2) { newValue in
      Task { await searchProducts(name: newValue) }
    }
    .confirmationDialog("Product Merge Confirmation",
                        isPresented: $showMergeToProductConfirmation,
                        presenting: mergeToProduct)
    { presenting in
      ProgressButton(
        """
        \(mode == .mergeDuplicate ? "Merge" : "Mark") \(presenting.name) \(
          mode == .mergeDuplicate ? "to" : "as duplicate of") \(presenting.getDisplayName(.fullName))
        """,
        role: .destructive
      ) {
        await primaryAction(onSuccess: {
          feedbackManager.trigger(.notification(.success))
          dismiss()
        })
      }
    }
  }

  func primaryAction(onSuccess: @escaping () -> Void) async {
    switch mode {
    case .reportDuplicate:
      await reportDuplicate(onSuccess: onSuccess)
    case .mergeDuplicate:
      await mergeProducts(onSuccess: onSuccess)
    }
  }

  func reportDuplicate(onSuccess: @escaping () -> Void) async {
    guard let mergeToProduct else { return }
    switch await repository.product.markAsDuplicate(
      productId: product.id,
      duplicateOfProductId: mergeToProduct.id
    ) {
    case .success:
      onSuccess()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger
        .error(
          "reporting duplicate product \(self.mergeToProduct?.id ?? 0) of \(mergeToProduct.id) failed: \(error.localizedDescription)"
        )
    }
  }

  func mergeProducts(onSuccess: @escaping () -> Void) async {
    guard let mergeToProduct else { return }
    switch await repository.product.mergeProducts(productId: product.id, toProductId: mergeToProduct.id) {
    case .success:
      onSuccess()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger
        .error("merging product \(self.mergeToProduct?.id ?? 0) to \(mergeToProduct.id) failed: \(error.localizedDescription)")
    }
  }

  func searchProducts(name: String) async {
    guard name.count > 1 else { return }
    switch await repository.product.search(searchTerm: name, filter: nil) {
    case let .success(searchResults):
      products = searchResults
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching products failed: \(error.localizedDescription)")
    }
  }
}
