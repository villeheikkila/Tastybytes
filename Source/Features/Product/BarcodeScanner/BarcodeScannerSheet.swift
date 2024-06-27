import AVFoundation
import Components
import Models
import SwiftUI

@MainActor
struct BarcodeScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBarcodeTextField = false
    @State private var barcodeInput = ""
    @State private var isTorchOn = false

    let onComplete: (_ barcode: Barcode) async -> Void

    var body: some View {
        VStack {
            if showBarcodeTextField {
                Form {
                    TextField("barcode.scanner.textInput.placeholder", text: $barcodeInput)
                        .keyboardType(.decimalPad)
                    ProgressButton("labels.submit", action: {
                        await onComplete(Barcode(barcode: barcodeInput, type: AVMetadataObject.ObjectType.ean13.rawValue))
                        dismiss()
                    })
                    .disabled(!isValidEAN13(input: barcodeInput))
                }
                .safeAreaPadding(.vertical)
            } else {
                #if !targetEnvironment(macCatalyst)
                    BarcodeDataScannerView { barcode in
                        await onComplete(barcode)
                        dismiss()
                    }
                #endif
            }
        }
        .ignoresSafeArea()
        .toolbar {
            toolbarContent
        }
        .onChange(of: isTorchOn) { _, newValue in
            setTorchIsOn(isOn: newValue)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .topBarTrailing) {
            Group {
                if !showBarcodeTextField {
                    Button(isTorchOn ? "torch.off.label" : "torch.on.label",
                           systemImage: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill",
                           action: { withAnimation { isTorchOn.toggle() } })
                }
                Button(showBarcodeTextField ? "barcode.scanner.showScanner.label" : "barcode.scanner.textInput.label",
                       systemImage: showBarcodeTextField ? "barcode.viewfinder" : "character.cursor.ibeam",
                       action: { withAnimation { showBarcodeTextField.toggle() } })
            }
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
    }

    func setTorchIsOn(isOn: Bool) {
        guard let device = AVCaptureDevice.userPreferredCamera else { return }
        guard device.hasTorch, device.isTorchAvailable else { return }
        try? device.lockForConfiguration()
        if isOn {
            try? device.setTorchModeOn(level: 1.0)
        } else {
            device.torchMode = .off
        }
        device.unlockForConfiguration()
    }
}
