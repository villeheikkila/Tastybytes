import Models
import SwiftUI

struct ProductListRowView: View {
    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product))) {
            ProductEntityView(product: product, extras: [.rating], averageRating: product.averageRating)
        }
    }
}
