import Components
import Models
import SwiftUI

struct CheckInCardProduct: View {
    let product: Product.Joined
    let loadedFrom: CheckInCard.LoadedFrom
    let productVariant: ProductVariant?
    let servingStyle: ServingStyle?

    var body: some View {
        RouterLink(open: .screen(.product(product))) {
            HStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    CategoryView(
                        category: product.category,
                        subcategories: product.subcategories,
                        servingStyle: servingStyle
                    )

                    Text(product.formatted(.fullName))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)

                    if let description = product.description {
                        Text(description)
                            .font(.caption)
                    }

                    HStack {
                        RouterLink(open: .screen(.company(product.subBrand.brand.brandOwner))) {
                            Text(product.formatted(.brandOwner))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                                .contentShape(.rect)
                                .accessibilityAddTraits(.isLink)
                        }

                        if let manufacturer = productVariant?.manufacturer,
                           manufacturer.id != product.subBrand.brand.brandOwner.id
                        {
                            RouterLink(open: .screen(.company(manufacturer))) {
                                Text("(\(manufacturer.name))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }
                if !product.logos.isEmpty {
                    ProductLogoView(product: product, size: 48)
                }
            }
            .contentShape(.rect)
            .accessibilityAddTraits(.isLink)
        }
        .allowsHitTesting(loadedFrom != .product)
    }
}
