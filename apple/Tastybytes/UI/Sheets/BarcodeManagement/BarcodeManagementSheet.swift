import SwiftUI

struct BarcodeManagementSheet: View {
  private let logger = getLogger(category: "BarcodeManagementSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss
  @State private var barcodes: [ProductBarcode.JoinedWithCreator] = []

  let product: Product.Joined

  var body: some View {
    Form {
      ForEach(barcodes) { barcode in
        HStack {
          AvatarView(avatarUrl: barcode.profile.avatarUrl, size: 32, id: barcode.profile.id)
          VStack(alignment: .leading, spacing: 2) {
            HStack {
              Text(barcode.profile.preferredName).font(.caption)
              Spacer()
              Text(barcode.createdAt.customFormat(.relativeTime)).font(.caption2)
            }
            Text(barcode.barcode).font(.callout)
          }
          Spacer()
        }
        .swipeActions {
          ProgressButton("Delete", systemImage: "trash.fill", role: .destructive, action: {
            await deleteBarcode(barcode)
            hapticManager.trigger(.notification(.success))
          })
        }
        .contextMenu {
          ProgressButton("Delete", systemImage: "trash.fill", role: .destructive, action: {
            await deleteBarcode(barcode)
            hapticManager.trigger(.notification(.success))
          })
        }
      }
    }
    .task {
      await getBarcodes()
    }
    .navigationTitle("Barcodes")
    .navigationBarItems(leading: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  func deleteBarcode(_ barcode: ProductBarcode.JoinedWithCreator) async {
    switch await repository.productBarcode.delete(id: barcode.id) {
    case .success:
      withAnimation {
        barcodes.remove(object: barcode)
      }
    case let .failure(error):
      logger.error("failed to fetch barcodes for product: \(error.localizedDescription)")
    }
  }

  func getBarcodes() async {
    switch await repository.productBarcode.getByProductId(id: product.id) {
    case let .success(barcodes):
      withAnimation {
        self.barcodes = barcodes
      }
    case let .failure(error):
      logger.error("failed to fetch barcodes for product: \(error.localizedDescription)")
    }
  }
}
