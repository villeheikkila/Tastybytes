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
        }).buttonStyle(.plain)
      }
    }
    .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a duplicate product")
    .disableAutocorrection(true)
    .onSubmit(of: .search) {
      Task { await searchProducts(name: searchTerm) }
    }
    .navigationTitle(mode == .mergeDuplicate ? "Merge duplicates" : "Mark as duplicate")
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

  func reportDuplicate(_ to: Product.Joined) async {
    switch await repository.product.markAsDuplicate(
      productId: product.id,
      duplicateOfProductId: to.id
    ) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger
        .error(
          "reporting duplicate product \(product.id) of \(to.id) failed: \(error.localizedDescription)"
        )
    }
  }

  func mergeProducts(_ to: Product.Joined) async {
    switch await repository.product.mergeProducts(productId: product.id, toProductId: to.id) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger
        .error("merging product \(product.id) to \(to.id) failed: \(error.localizedDescription)")
    }
  }

  func searchProducts(name: String) async {
    guard name.count > 1 else { return }
    switch await repository.product.search(searchTerm: name, filter: nil) {
    case let .success(searchResults):
      products = searchResults
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching products failed: \(error.localizedDescription)")
    }
  }
}
