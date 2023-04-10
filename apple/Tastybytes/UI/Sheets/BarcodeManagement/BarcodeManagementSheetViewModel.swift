import SwiftUI

extension BarcodeManagementSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BarcodeManagementSheet")
    let client: Client
    let product: Product.Joined
    @Published var barcodes: [ProductBarcode.JoinedWithCreator] = []

    init(_ client: Client, product: Product.Joined) {
      self.client = client
      self.product = product
    }

    func deleteBarcode(_ barcode: ProductBarcode.JoinedWithCreator) {
      Task {
        switch await client.productBarcode.delete(id: barcode.id) {
        case .success:
          withAnimation {
            self.barcodes.remove(object: barcode)
          }
        case let .failure(error):
          logger.error("failed to fetch barcodes for product: \(error.localizedDescription)")
        }
      }
    }

    func getBarcodes() {
      Task {
        switch await client.productBarcode.getByProductId(id: product.id) {
        case let .success(barcodes):
          withAnimation {
            self.barcodes = barcodes
          }
        case let .failure(error):
          logger.error("failed to fetch barcodes for product: \(error.localizedDescription)")
        }
      }
    }
  }
}
