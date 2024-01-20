import Models
import SwiftUI

struct DiscoverProductAddNew: View {
    @Environment(Router.self) private var router
    @Binding var barcode: Barcode?

    var body: some View {
        Section("Didn't find a product you were looking for?") {
            HStack {
                Text("Add new")
                    .fontWeight(.medium)
                Spacer()
            }
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                let barcodeCopy = barcode
                barcode = nil
                router.navigate(screen: .addProduct(barcodeCopy))
            }
        }
    }
}
