import SwiftUI

extension ProductVerificationScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductVerificationScreen")
    let client: Client
    @Published var products = [Product.Joined]()

    init(_ client: Client) {
      self.client = client
    }

    func verifyProduct(_ product: Product.Joined) {
      Task {
        switch await client.product.verification(id: product.id, isVerified: true) {
        case .success:
          withAnimation {
            products.remove(object: product)
          }
        case let .failure(error):
          logger.error("failed to verify product \(product.id): \(error.localizedDescription)")
        }
      }
    }

    func loadProducts() async {
      switch await client.product.getFeed(.unverified, from: 0, to: 1000, categoryFilterId: nil) {
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
