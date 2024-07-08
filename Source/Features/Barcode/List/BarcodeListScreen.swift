import Models
import SwiftUI

struct BarcodeListScreen: View {
    let barcodes: [ProductBarcode.Joined]

    var body: some View {
        List(barcodes) { barcode in
            BarcodeListRowView(barcode: barcode)
        }
        .listStyle(.plain)
        .navigationTitle("barcode.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BarcodeListRowView: View {
    let barcode: ProductBarcode.Joined

    var body: some View {
        RouterLink(open: .screen(.product(barcode.product))) {
            VStack(alignment: .leading, spacing: 4) {
                ProductEntityView(product: barcode.product)
                Text(barcode.barcode)
            }
        }
    }
}
