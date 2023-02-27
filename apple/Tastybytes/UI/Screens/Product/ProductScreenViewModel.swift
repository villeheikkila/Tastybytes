import SwiftUI

extension ProductScreen {
  enum Sheet: Identifiable {
    var id: Self { self }
    case checkIn
    case barcodes
    case editSuggestion
    case editProduct
    case barcodeScanner
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductScreen")
    let client: Client
    @Published var product: Product.Joined
    @Published var activeSheet: Sheet?
    @Published var summary: Summary?
    @Published var showDeleteProductConfirmationDialog = false
    @Published var showUnverifyProductConfirmation = false
    @Published var resetView: Int = 0

    init(_ client: Client, product: Product.Joined) {
      self.product = product
      self.client = client
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func showDeleteConfirmation() {
      showDeleteProductConfirmationDialog.toggle()
    }

    func onEditProduct() {
      activeSheet = nil
      refresh()
      refreshCheckIns()
    }

    func loadSummary() {
      Task {
        switch await client.product.getSummaryById(id: product.id) {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger.error("failed to load product summary for '\(self.product.id)': \(error.localizedDescription)")
        }
      }
    }

    func refresh() {
      Task {
        async let productPromise = client.product.getById(id: product.id)
        async let summaryPromise = client.product.getSummaryById(id: product.id)

        switch await productPromise {
        case let .success(refreshedProduct):
          withAnimation {
            product = refreshedProduct
          }
        case let .failure(error):
          logger.error("failed to refresh product by id '\(self.product.id)': \(error.localizedDescription)")
        }

        switch await summaryPromise {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger.error("failed to load product summary for '\(self.product.id)': \(error.localizedDescription)")
        }
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
      refresh()
      resetView += 1
    }

    func verifyProduct(isVerified: Bool) {
      Task {
        switch await client.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
          refresh()
        case let .failure(error):
          logger.error("failed to verify product \(self.product.id): \(error.localizedDescription)")
        }
      }
    }

    func deleteProduct(onDelete: @escaping () -> Void) {
      Task {
        switch await client.product.delete(id: product.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger.error("failed to delete product \(self.product.id): \(error.localizedDescription)")
        }
      }
    }
  }
}
