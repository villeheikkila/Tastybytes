import Models
import SwiftUI

struct ProductListAdminScreen: View {
    @Binding var products: [Product.Joined]

    var body: some View {
        List(products) { product in
            RouterLink(open: .sheet(.productAdmin(id: product.id, onUpdate: { product in
                products = products.replacingWithId(product.id, with: .init(product: product))
            }, onDelete: { id in
                products = products.removingWithId(id)
            }))) {
                ProductView(product: product)
            }
        }
        .listStyle(.plain)
        .navigationTitle("productListAdmin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
