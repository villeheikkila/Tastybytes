import Components
import SwiftUI

struct ProductLoadedFromBarcodeOverlay: View {
    @Environment(Router.self) private var router
    @Binding var loadedWithBarcode: Barcode?

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Not the product you were looking for?")
                    HStack {
                        Button("Back to search") {
                            router.removeLast()
                        }
                    }
                }
                .padding(.vertical, 10)
                Spacer()
                CloseButtonView {
                    loadedWithBarcode = nil
                }
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .padding(.horizontal, 10)
            .background(.thinMaterial)
            Spacer()
        }
    }
}
