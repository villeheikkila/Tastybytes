import SwiftUI

extension ProductScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductScreen")
    let client: Client
    @Published var product: Product.Joined
    @Published var summary: Summary?
    @Published var showDeleteProductConfirmationDialog = false
    @Published var showUnverifyProductConfirmation = false
    @Published var resetView: Int = 0

    init(_ client: Client, product: Product.Joined) {
      self.product = product
      self.client = client
    }

    func showDeleteConfirmation() {
      showDeleteProductConfirmationDialog.toggle()
    }

    func onEditProduct() async {
      await refresh()
      await refreshCheckIns()
    }

    func loadSummary() async {
      switch await client.product.getSummaryById(id: product.id) {
      case let .success(summary):
        self.summary = summary
      case let .failure(error):
        logger.error("failed to load product summary: \(error.localizedDescription)")
      }
    }

    func refresh() async {
      async let productPromise = client.product.getById(id: product.id)
      async let summaryPromise = client.product.getSummaryById(id: product.id)

      switch await productPromise {
      case let .success(refreshedProduct):
        withAnimation {
          product = refreshedProduct
        }
      case let .failure(error):
        logger.error("failed to refresh product by id: \(error.localizedDescription)")
      }

      switch await summaryPromise {
      case let .success(summary):
        self.summary = summary
      case let .failure(error):
        logger.error("failed to load product summary: \(error.localizedDescription)")
      }
    }

    func addBarcodeToProduct(barcode: Barcode, onComplete: @escaping () -> Void) {
      Task {
        switch await client.productBarcode.addToProduct(product: product, barcode: barcode) {
        case .success:
          onComplete()
        case let .failure(error):
          logger
            .error(
              "adding barcode \(barcode.barcode) to product \(self.product.id) failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func refreshCheckIns() {
      Task {
        await refresh()
        resetView += 1
      }
    }

    func verifyProduct(isVerified: Bool) async {
      switch await client.product.verification(id: product.id, isVerified: isVerified) {
      case .success:
        await refresh()
      case let .failure(error):
        logger.error("failed to verify product: \(error.localizedDescription)")
      }
    }

    func deleteProduct(onDelete: @escaping () -> Void) async {
      switch await client.product.delete(id: product.id) {
      case .success:
        onDelete()
      case let .failure(error):
        logger.error("failed to delete product: \(error.localizedDescription)")
      }
    }
  }
}
