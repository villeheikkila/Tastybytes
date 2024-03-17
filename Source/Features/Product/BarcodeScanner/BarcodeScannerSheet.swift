import AVFoundation
import Components
import LegacyUIKit
import Models
import SwiftUI
import VisionKit

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
                DataScannerViewRepresentable(recognizedDataTypes: [.barcode(symbologies: [.codabar, .code39, .ean8, .ean13])], onDataFound: { data in
                    if case let .barcode(foundBarcode) = data {
                        guard let payloadStringValue = foundBarcode.payloadStringValue else { return }
                        onComplete(.init(barcode: payloadStringValue, type: ""))
                        dismiss()
                    }
                })
            }
        }
        .navigationTitle("barcode.scanner.navigationTitle")
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

    func setTorchIsOn(isOn: Bool) {
        guard let device = AVCaptureDevice.userPreferredCamera else { return }

        if device.hasTorch, device.isTorchAvailable {
            do {
                try device.lockForConfiguration()
                if isOn {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {}
        }
    }
}

struct DataScannerViewRepresentable: UIViewControllerRepresentable {
    typealias DataFoundCallback = (RecognizedItem) -> Void
    let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    let onDataFound: DataScannerViewRepresentable.DataFoundCallback

    func makeUIViewController(context _: Context) -> DataScannerViewController {
        DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDataFound: onDataFound)
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator _: Coordinator) {
        uiViewController.stopScanning()
    }
}

class Coordinator: NSObject, DataScannerViewControllerDelegate {
    let onDataFound: DataScannerViewRepresentable.DataFoundCallback

    init(onDataFound: @escaping DataScannerViewRepresentable.DataFoundCallback) {
        self.onDataFound = onDataFound
    }

    func dataScanner(_: DataScannerViewController, didTapOn _: RecognizedItem) {}

    func dataScanner(_: DataScannerViewController, didAdd: [RecognizedItem], allItems _: [RecognizedItem]) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if let found = didAdd.first {
            onDataFound(found)
        }
    }

    func dataScanner(_: DataScannerViewController, didRemove _: [RecognizedItem], allItems _: [RecognizedItem]) {}

    func dataScanner(_: DataScannerViewController, becameUnavailableWithError _: DataScannerViewController.ScanningUnavailable) {}
}
