import Components
import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProductEntityView: View {
    @Environment(\.verificationBadgeVisibility) private var verificationBadgeVisibility

    enum Extra {
        case checkInCheck, rating, companyLink, logoOnLeft, logoOnRight
    }

    let product: ProductProtocol
    let extras: Set<Extra>
    let isCheckedIn: Bool
    let averageRating: Double?

    init(product: ProductProtocol, extras: Set<Extra> = Set(), isCheckedIn: Bool = false, averageRating: Double? = nil) {
        self.product = product
        self.extras = extras
        self.isCheckedIn = isCheckedIn
        self.averageRating = averageRating
    }

    var body: some View {
        HStack(spacing: 12) {
            if extras.contains(.logoOnLeft) {
                productLogo
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.formatted(.fullName))
                        .font(.headline)
                        .textSelection(.enabled)
                    if verificationBadgeVisibility == .visible, product.isVerified {
                        VerifiedBadgeView()
                    }

                    Spacer()
                    if isCheckedIn, extras.contains(.checkInCheck) {
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

                RouterLink(open: .screen(.company(product.subBrand.brand.brandOwner))) {
                    Text(product.formatted(.brandOwner))
                        .font(.subheadline)
                        .textSelection(.enabled)
                        .foregroundColor(.secondary)
                }
                .routerLinkDisabled(!extras.contains(.companyLink))
                .routerLinkMode(.button)
                .buttonStyle(.plain)

                HStack {
                    CategoryView(category: product.category, subcategories: product.subcategories)
                    Spacer()
                    if let averageRating, extras.contains(.rating) {
                        RatingView(rating: averageRating)
                            .ratingSize(.small)
                    }
                }
            }
            if extras.contains(.logoOnRight) {
                productLogo
            }
        }
    }

    private var productLogo: some View {
        ProductLogoView(product: product, size: 48)
    }
}
