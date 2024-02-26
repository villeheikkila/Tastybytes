import AVFoundation
import Components
import LegacyUIKit
import Models
import SwiftUI

@MainActor
struct BarcodeScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBarcodeTextField = false
    @State private var barcodeInput = ""
    @State private var isTorchOn = false

    let onComplete: (_ barcode: Barcode) -> Void

    var body: some View {
        VStack {
            if showBarcodeTextField {
                Form {
                    TextField("barcode.scanner.textInput.placeholder", text: $barcodeInput)
                        .keyboardType(.decimalPad)
                    Button("labels.submit", action: {
                        onComplete(Barcode(barcode: barcodeInput, type: AVMetadataObject.ObjectType.ean13.rawValue))
                        dismiss()
                    }).disabled(!isValidEAN13(input: barcodeInput))
                }
            } else {
                ScannerView(scanTypes: [.codabar, .code39, .ean8, .ean13], completion: { response in
                    if case let .success(result) = response {
                        onComplete(Barcode(barcode: result.barcode, type: result.type))
                        dismiss()
                    }
                }, isTorchOn: isTorchOn)
            }
        }
        .navigationTitle("barcode.scanner.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .topBarTrailing) {
            Group {
                Button(isTorchOn ? "torch.off.label" : "torch.on.label",
                       systemImage: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill",
                       action: { withAnimation { isTorchOn.toggle() } })
                    .opacity(showBarcodeTextField ? 0 : 1)
                Button(showBarcodeTextField ? "barcode.scanner.showScanner.label" : "barcode.scanner.textInput.label",
                       systemImage: showBarcodeTextField ? "barcode.viewfinder" : "character.cursor.ibeam",
                       action: { withAnimation { showBarcodeTextField.toggle() } })
            }
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
    }
}
