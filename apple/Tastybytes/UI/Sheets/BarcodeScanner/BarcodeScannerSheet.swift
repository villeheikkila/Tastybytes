import AVFoundation
import SwiftUI

struct BarcodeScannerSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showBarcodeTextField = false
  @State private var barcodeInput = ""

  let onComplete: (_ barcode: Barcode) -> Void

  func createBarcodeFromTextInput() -> Barcode {
    Barcode(barcode: barcodeInput, type: AVMetadataObject.ObjectType.ean13)
  }
    
  func isValidEAN13(input: String) -> Bool {
    if input.count != 13 { return false }
    let parts = input.compactMap(\.wholeNumberValue)
    if parts.count != 13 { return false }
    let evenSumMultiplied = (parts[0] + parts[2] + parts[4] + parts[6] + parts[8] + parts[10]) * 3
    let oddSum = parts[1] + parts[3] + parts[5] + parts[7] + parts[9] + parts[11]
    let reminder = (evenSumMultiplied + oddSum) % 10
    let checkValue = reminder == 0 ? reminder : 10 - reminder
    let checkDigit = parts[12]
    return checkValue == checkDigit
  }

  var body: some View {
    Group {
      if showBarcodeTextField {
        Form {
          TextField("Barcode (EAN13)", text: $barcodeInput)
            .keyboardType(.decimalPad)
          Button(action: { onComplete(createBarcodeFromTextInput()) }, label: {
            Text("Submit")
          }).disabled(!isValidEAN13(input: barcodeInput))
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
    }), trailing: Button(action: { showBarcodeTextField = true }, label: {
      Label("Add barcode manually", systemImage: "character.cursor.ibeam")
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }))
  }
}
