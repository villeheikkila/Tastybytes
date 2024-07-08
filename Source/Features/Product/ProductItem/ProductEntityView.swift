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

    let product: Product.Joined
    let extras: Set<Extra>

    init(product: Product.Joined, extras: Set<Extra> = Set()) {
        self.product = product
        self.extras = extras
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
                    if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0,
                       extras.contains(.checkInCheck)
                    {
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

                Text(product.formatted(.brandOwner))
                    .font(.subheadline)
                    .textSelection(.enabled)
                    .foregroundColor(.secondary)
                    .if(extras.contains(.companyLink), transform: { view in
                        view.contentShape(.rect)
                            .accessibilityAddTraits(.isLink)
                            .openOnTap(.screen(.company(product.subBrand.brand.brandOwner)))
                    })

                HStack {
                    CategoryView(category: product.category, subcategories: product.subcategories)
                    Spacer()
                    if let averageRating = product.averageRating, extras.contains(.rating) {
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
        ProductLogo(product: product, size: 48)
    }
}

struct VerifiedBadgeView: View {
    var body: some View {
        Label("label.isVerified", systemImage: "checkmark.seal")
            .labelStyle(.iconOnly)
            .foregroundColor(.green)
    }
}
