import Models
import SwiftUI

struct BarcodeListScreen: View {
    let barcodes: [Product.Barcode.Joined]

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
    let barcode: Product.Barcode.Joined

    var body: some View {
        RouterLink(open: .screen(.product(barcode.product.id))) {
            VStack(alignment: .leading, spacing: 8) {
                ProductView(product: barcode.product)
                BarcodeView(barcode: barcode.barcode)
            }
        }
    }
}
