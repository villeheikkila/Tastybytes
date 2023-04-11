import SwiftUI

extension DuplicateProductScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductVerificationScreen")
    let client: Client
    @Published var products = [Product.Joined]()
    @Published var deleteProduct: Product.Joined? {
      didSet {
        showDeleteProductConfirmationDialog = true
      }
    }

    @Published var showDeleteProductConfirmationDialog = false

    init(_ client: Client) {
      self.client = client
    }

    func verifyProduct(_ product: Product.Joined) async {
      switch await client.product.verification(id: product.id, isVerified: true) {
      case .success:
        withAnimation {
          products.remove(object: product)
        }
      case let .failure(error):
        logger.error("failed to verify product \(product.id): \(error.localizedDescription)")
      }
    }

    func deleteProduct(onDelete: @escaping () -> Void) async {
      guard let deleteProduct else { return }
      switch await client.product.delete(id: deleteProduct.id) {
      case .success:
        onDelete()
      case let .failure(error):
        logger.error("failed to delete product \(deleteProduct.id): \(error.localizedDescription)")
      }
    }

    func loadProducts() async {
      switch await client.product.getUnverified() {
      case let .success(products):
        withAnimation {
          self.products = products
        }
      case let .failure(error):
        logger
          .error(
            "fetching flavors failed: \(error.localizedDescription)"
          )
      }
    }
  }
}
