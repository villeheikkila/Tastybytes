import AVFoundation
import SwiftUI

struct BarcodeScannerSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showBarcodeTextField = false
  @State private var barcodeInput = ""
  @State private var isTorchOn = false

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
        ScannerView(scanTypes: [.codabar, .code39, .ean8, .ean13], completion: { response in
          if case let .success(result) = response {
            onComplete(result)
            dismiss()
          }
        }, isTorchOn: isTorchOn)
      }
    }
    .navigationTitle("Barcode Scanner")
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button(role: .cancel, action: { dismiss() }, label: {
        Text("Cancel")
          .bold()
      })
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: { withAnimation { showBarcodeTextField.toggle() } }, label: {
        Label(
          showBarcodeTextField ? "Show scanner" : "Add barcode manually",
          systemImage: showBarcodeTextField ? "barcode.viewfinder" : "character.cursor.ibeam"
        )
        .labelStyle(.iconOnly)
        .imageScale(.large)
      })
      Button(action: { withAnimation { isTorchOn.toggle() } }, label: {
        Label(
          "Turn the torch \(isTorchOn ? "off" : "on")",
          systemImage: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill"
        )
        .labelStyle(.iconOnly)
        .imageScale(.large)
      })
    }
  }
}
