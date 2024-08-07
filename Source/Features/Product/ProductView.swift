import Components
import Models
import Repositories
import SwiftUI

struct ProductView: View {
    @Environment(\.productLogoLocation) private var productLogoLocation
    @Environment(\.productCompanyLinkEnabled) private var productCompanyLinkEnabled

    let product: Product.Joined
    let variant: Product.Variant.JoinedCompany?

    init(product: Product.Joined, variant: Product.Variant.JoinedCompany? = nil) {
        self.product = product
        self.variant = variant
    }

    var body: some View {
        HStack(spacing: 12) {
            if productLogoLocation == .left {
                productLogo
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.formatted(.fullName))
                        .font(.headline)
                        .textSelection(.enabled)
                    VerifiedBadgeView(verifiable: product)
                    Spacer()
                    if product.isCheckedInByCurrentUser {
                        Label("checkIn.checkedIn.label", systemImage: "checkmark.circle")
                            .labelStyle(.iconOnly)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, .secondary)
                            .imageScale(.small)
                    }
                }
                if let description = product.description {
                    Text(description)
                        .font(.caption)
                        .textSelection(.enabled)
                }

                HStack {
                    RouterLink(open: .screen(.company(product.subBrand.brand.brandOwner.id))) {
                        Text(product.formatted(.brandOwner))
                            .font(.subheadline)
                            .textSelection(.enabled)
                            .foregroundColor(.secondary)
                    }
                    .routerLinkDisabled(!productCompanyLinkEnabled)
                    .routerLinkMode(.button)
                    .buttonStyle(.plain)

                    if let manufacturer = variant?.manufacturer,
                       manufacturer.id != product.subBrand.brand.brandOwner.id
                    {
                        RouterLink(open: .screen(.company(manufacturer.id))) {
                            Text("(\(manufacturer.name))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack {
                    ProductLabelsView(category: product.category, subcategories: product.subcategories)
                    Spacer()
                    if let averageRating = product.averageRating {
                        RatingView(rating: averageRating)
                            .ratingSize(.small)
                    }
                }
            }
            if productLogoLocation == .right {
                productLogo
            }
        }
    }

    private var productLogo: some View {
        ProductLogoView(product: product, size: 48)
    }
}

enum ProductLogoLocation {
    case hidden, left, right
}

extension EnvironmentValues {
    @Entry var productLogoLocation: ProductLogoLocation = .hidden
}

extension View {
    func productLogoLocation(_ visibility: ProductLogoLocation) -> some View {
        environment(\.productLogoLocation, visibility)
    }
}

extension EnvironmentValues {
    @Entry var productCompanyLinkEnabled: Bool = false
}

extension View {
    func productCompanyLinkEnabled(_ enabled: Bool) -> some View {
        environment(\.productCompanyLinkEnabled, enabled)
    }
}
