import Models
import SwiftUI

struct BarcodeListScreen: View {
    let barcodes: [ProductBarcode.Joined]

    var body: some View {
        List(barcodes) { barcode in
            Text(barcode.barcode)
        }
        .listStyle(.plain)
        .navigationTitle("barcode.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
