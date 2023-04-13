import SwiftUI

extension DuplicateProductSheet {
  enum Mode {
    case mergeDuplicate, reportDuplicate
  }

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "MarkAsDuplicate")
    let client: Client
    @Published var products = [Product.Joined]()
    @Published var currentUserProductDuplicateSuggestions = [ProductDuplicateSuggestion]()
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
      switch await client.product.markAsDuplicate(
        productId: product.id,
        duplicateOfProductId: mergeToProduct.id
      ) {
      case .success:
        onSuccess()
      case let .failure(error):
        logger.error("reporting duplicate product \(self.mergeToProduct?.id ?? 0) of \(mergeToProduct.id) failed: \(error.localizedDescription)")
      }
    }

    func mergeProducts(onSuccess: @escaping () -> Void) async {
      guard let mergeToProduct else { return }
      switch await client.product.mergeProducts(productId: product.id, toProductId: mergeToProduct.id) {
      case .success:
        onSuccess()
      case let .failure(error):
        logger.error("merging product \(self.mergeToProduct?.id ?? 0) to \(mergeToProduct.id) failed: \(error.localizedDescription)")
      }
    }

    func searchProducts() async {
      switch await client.product.search(searchTerm: searchTerm, filter: nil) {
      case let .success(searchResults):
        products = searchResults
      case let .failure(error):
        logger.error("searching products failed: \(error.localizedDescription)")
      }
    }
  }
}
