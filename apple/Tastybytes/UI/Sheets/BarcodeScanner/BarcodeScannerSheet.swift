import AVFoundation
import SwiftUI

struct BarcodeScannerSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showBarcodeTextField = false
  @State private var barcodeInput = ""

  let onComplete: (_ barcode: Barcode) -> Void

  var body: some View {
    Group {
      if showBarcodeTextField {
        Form {
          TextField("Barcode (EAN13)", text: $barcodeInput)
            .keyboardType(.decimalPad)
          Button(
            action: { onComplete(Barcode(barcode: barcodeInput, type: AVMetadataObject.ObjectType.ean13)) },
            label: {
              Text("Submit")
            }
          ).disabled(!isValidEAN13(input: barcodeInput))
        }

      } else {
        ScannerView(scanTypes: [.codabar, .code39, .ean8, .ean13]) { response in
          if case let .success(result) = response {
            onComplete(result)
            dismiss()
          }
        }
      }
    }
    .navigationTitle("Barcode Scanner")
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Cancel").bold()
    }), trailing: Button(action: { withAnimation { showBarcodeTextField.toggle() } }, label: {
      Label(
        showBarcodeTextField ? "Show scanner" : "Add barcode manually",
        systemImage: showBarcodeTextField ? "barcode.viewfinder" : "character.cursor.ibeam"
      )
      .labelStyle(.iconOnly)
      .imageScale(.large)
    }))
  }
}
