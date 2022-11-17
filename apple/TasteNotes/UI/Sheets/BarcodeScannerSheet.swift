import SwiftUI

struct BarcodeScannerSheetView: View {
    let onComplete: (_ scannedCode: String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            BarcodeScannerView() { response in
                if case let .success(result) = response {
                    onComplete(result.code)
                    dismiss()
                }
            }
            .navigationTitle("Barcode Scanner")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}
