import SwiftUI

extension MergeSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "MergeSheetView")
    let client: Client
    @Published var mergeToProduct: Product.Joined?
    @Published var isPresentingProductMergeConfirmation = false
    @Published var productSearchTerm = ""
    @Published var productSearchResults: [Product.Joined] = []

    init(_ client: Client) {
      self.client = client
    }

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

    func searchProducts(productToMerge: Product.JoinedCategory) {
      Task {
        switch await client.product.search(searchTerm: productSearchTerm, filter: nil) {
        case let .success(searchResults):
          self.productSearchResults = searchResults.filter { $0.id != productToMerge.id }
        case let .failure(error):
          logger
            .error(
              "searching products for merge with ter, \(self.productSearchTerm) failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
