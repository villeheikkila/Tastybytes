import Components
import Models
import SwiftUI

struct CheckInCardProduct: View {
    @Environment(Router.self) private var router

    public let product: Product.Joined
    public let loadedFrom: CheckInCard.LoadedFrom
    public let productVariant: ProductVariant?
    public let servingStyle: ServingStyle?

    var body: some View {
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
                    Text(product.formatted(.brandOwner))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                        .contentShape(Rectangle())
                        .accessibilityAddTraits(.isLink)
                        .onTapGesture {
                            router.open(.screen(.company(product.subBrand.brand.brandOwner)))
                        }

                    if let manufacturer = productVariant?.manufacturer,
                       manufacturer.id != product.subBrand.brand.brandOwner.id
                    {
                        Text("(\(manufacturer.name))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
            if !product.logos.isEmpty {
                ProductLogo(product: product, size: 48)
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isLink)
        .allowsHitTesting(loadedFrom != .product)
        .onTapGesture {
            router.open(.screen(.product(product)))
        }
    }
}
