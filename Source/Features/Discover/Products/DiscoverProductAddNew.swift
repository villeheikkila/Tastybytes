import Models
import SwiftUI

struct DiscoverProductAddNew: View {
    @Environment(Router.self) private var router
    @Binding var barcode: Barcode?

    var body: some View {
        Section("product.createNew.description") {
            Button("product.createNew.label") {
                let barcodeCopy = barcode
                barcode = nil
                router.open(.sheet(.product(.new(barcode: barcodeCopy, onCreate: { product in
                    router.open(.screen(.product(product)))
                }))))
            }
            .fontWeight(.medium)
            .contentShape(.rect)
        }
    }
}
