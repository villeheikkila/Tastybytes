import Components
import SwiftUI

struct BarcodeView: View {
    let barcode: String

    var body: some View {
        if isValidEAN13(input: barcode) {
            EAN13View(barcode: barcode)
                .frame(width: 150, height: 50)
        } else {
            Text(barcode)
                .font(.callout)
        }
    }
}
