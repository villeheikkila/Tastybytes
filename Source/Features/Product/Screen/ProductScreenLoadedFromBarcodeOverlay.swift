import Components
import Models
import SwiftUI

struct ProductScreenLoadedFromBarcodeOverlay: View {
    @Environment(Router.self) private var router
    @Binding var loadedWithBarcode: Barcode?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("product.loadedFromBarcode.title")
                HStack {
                    Button("product.loadedFromBarcode.backToSearch") {
                        router.removeLast()
                    }
                }
            }
            .padding(.vertical, 10)
            Spacer()
            CloseButton {
                loadedWithBarcode = nil
            }
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
        .padding(.horizontal, 10)
        .background(.thinMaterial)
    }
}
