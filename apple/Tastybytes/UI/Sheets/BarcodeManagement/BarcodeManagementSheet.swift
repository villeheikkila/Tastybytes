import SwiftUI

struct BarcodeManagementSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, product: Product.Joined) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, product: product))
  }

  var body: some View {
    Form {
      ForEach(viewModel.barcodes) { barcode in
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
            await viewModel.deleteBarcode(barcode)
            hapticManager.trigger(.notification(.success))
          })
        }
        .contextMenu {
          ProgressButton("Delete", systemImage: "trash.fill", role: .destructive, action: {
            await viewModel.deleteBarcode(barcode)
            hapticManager.trigger(.notification(.success))
          })
        }
      }
    }
    .task {
      await viewModel.getBarcodes()
    }
    .navigationTitle("Barcodes")
    .navigationBarItems(leading: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }
}
