import SwiftUI

struct BarcodeManagementSheetView: View {
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
              Text(barcode.createdAt.relativeTime()).font(.caption2)
            }
            Text(barcode.barcode).font(.callout)
          }
          Spacer()
        }
        .contextMenu {
          Button(role: .destructive, action: {
            viewModel.deleteBarcode(barcode)
            hapticManager.trigger(of: .notification(.success))
          }) {
            Label("Delete", systemImage: "trash.fill")
          }
        }
      }
    }
    .onAppear {
      viewModel.getBarcodes()
    }
    .navigationTitle("Barcodes")
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }) {
      Text("Cancel").bold()
    })
  }
}
