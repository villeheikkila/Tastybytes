import Models
import SwiftUI

struct DiscoverProductAddNew: View {
    @Environment(Router.self) private var router
    @Binding var barcode: Barcode?

    var body: some View {
        Section("product.createNew.description") {
            HStack {
                Text("product.createNew.label")
                    .fontWeight(.medium)
                Spacer()
            }
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                let barcodeCopy = barcode
                barcode = nil
                router.open(.screen(.addProduct(barcodeCopy)))
            }
        }
    }
}
