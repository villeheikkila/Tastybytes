import Models
import SwiftUI

struct CompanyProductVariantsScreen: View {
    let variants: [Product.Variant.JoinedProduct]

    var body: some View {
        List(variants) { variant in
            CompanyProductVariantRowView(variant: variant)
        }
        .listStyle(.plain)
        .navigationTitle("product.admin.variants.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CompanyProductVariantRowView: View {
    let variant: Product.Variant.JoinedProduct

    var body: some View {
        RouterLink(open: .sheet(.productAdmin(id: variant.product.id))) {
            ProductEntityView(product: variant.product)
        }
    }
}
