import BarcodeGeneratorKit
import Components
import SwiftUI

struct BarcodeView: View {
    let barcode: String

    var body: some View {
        if let barcode: BarcodeGeneratorKit.Barcode = .init(rawValue: barcode) {
            BarcodeGenerator(barcode: barcode) {
                fallback
            }
            .frame(width: 200, height: 80)
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Text(barcode)
            .font(.callout)
    }
}
