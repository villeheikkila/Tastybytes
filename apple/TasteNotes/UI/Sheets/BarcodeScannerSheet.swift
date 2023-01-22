import SwiftUI

struct BarcodeScannerSheetView: View {
  @Environment(\.dismiss) private var dismiss
  let onComplete: (_ barcode: Barcode) -> Void

  var body: some View {
    BarcodeScannerView { response in
      if case let .success(result) = response {
        onComplete(result)
        dismiss()
      }
    }
    .navigationTitle("Barcode Scanner")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
  }
}
