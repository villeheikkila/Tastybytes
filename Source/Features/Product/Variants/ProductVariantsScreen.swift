import Models
import SwiftUI

struct ProductVariantsScreen: View {
    let variants: [Product.Variant.JoinedCompany]

    var body: some View {
        List(variants) { variant in
            ProductVariantRowView(variant: variant)
        }
        .listStyle(.plain)
        .navigationTitle("product.admin.variants.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProductVariantRowView: View {
    let variant: Product.Variant.JoinedCompany

    var body: some View {
        RouterLink(open: .sheet(.companyAdmin(id: variant.manufacturer.id))) {
            CompanyEntityView(company: variant.manufacturer)
        }
    }
}
