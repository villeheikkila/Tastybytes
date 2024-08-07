import Models
import SwiftUI

struct ProductListRowView: View {
    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product.id))) {
            ProductView(product: product)
        }
    }
}
