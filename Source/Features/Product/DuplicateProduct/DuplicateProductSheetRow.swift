import Models
import SwiftUI

@MainActor
struct DuplicateProductSheetRow: View {
    let product: Product.Joined
    let onClick: (_ product: Product.Joined) -> Void

    var body: some View {
        Button(action: { onClick(product) }, label: {
            HStack {
                ProductItemView(product: product)
                Spacer()
            }
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
    }
}
