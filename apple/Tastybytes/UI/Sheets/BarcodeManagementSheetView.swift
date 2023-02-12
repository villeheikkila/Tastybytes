import SwiftUI

struct BarcodeManagementSheetView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, product: Product.Joined) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, product: product))
  }

  var body: some View {
    List {
      ForEach(viewModel.barcodes) { barcode in
        HStack {
          AvatarView(avatarUrl: barcode.profile.avatarUrl, size: 32, id: barcode.profile.id)
          VStack(alignment: .leading) {
            HStack {
              Text(barcode.profile.preferredName).font(.system(size: 12, weight: .medium, design: .default))
              Spacer()
              Text(barcode.createdAt.relativeTime()).font(.system(size: 8, weight: .medium, design: .default))
            }
            Text(barcode.barcode).font(.system(size: 14, weight: .light, design: .default))
          }
          Spacer()
        }
        .contextMenu {
          Button(action: {
            viewModel.deleteBarcode(barcode)
          }) {
            Label("Delete", systemImage: "trash.fill")
              .foregroundColor(.red)
          }
        }
      }
    }
    .onAppear {
      viewModel.getBarcodes()
    }
    .navigationTitle("Barcodes")
  }
}

extension BarcodeManagementSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BarcodeManagementSheetView")
    let client: Client
    let product: Product.Joined
    @Published var barcodes: [ProductBarcode.JoinedWithCreator] = []

    init(_ client: Client, product: Product.Joined) {
      self.client = client
      self.product = product
    }

    func deleteBarcode(_ barcode: ProductBarcode.JoinedWithCreator) {
      Task {
        switch await client.productBarcode.delete(id: product.id) {
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
