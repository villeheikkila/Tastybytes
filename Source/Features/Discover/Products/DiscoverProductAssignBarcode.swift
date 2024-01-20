import Models
import SwiftUI

struct DiscoverProductAssignBarcode: View {
    let isEmpty: Bool
    @Binding var barcode: Barcode?

    var body: some View {
        Section {
            Text(
                """
                \(isEmpty ? "No results were found" : "If none of the results match"),\
                you can assign the barcode to a product by searching again \
                with the name or by creating a new product.
                """
            )
            Button("Dismiss barcode", action: {
                barcode = nil
            })
        }
    }
}
