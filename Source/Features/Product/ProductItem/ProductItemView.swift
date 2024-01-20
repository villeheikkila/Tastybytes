import Components
import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProductItemView: View {
    enum Extra {
        case checkInCheck, rating, companyLink, logo
    }

    @Environment(Router.self) private var router
    let product: Product.Joined
    let extras: Set<Extra>

    init(product: Product.Joined, extras: Set<Extra> = Set()) {
        self.product = product
        self.extras = extras
    }

    var body: some View {
        HStack(spacing: 12) {
            if extras.contains(.logo) {
                ProductLogo(product: product, size: 48)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.getDisplayName(.fullName))
                        .font(.headline)
                    Spacer()
                    if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0,
                       extras.contains(.checkInCheck)
                    {
                        Label("Checked-in", systemImage: "checkmark.circle")
                            .labelStyle(.iconOnly)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, .secondary)
                            .imageScale(.small)
                    }
                }
                if let description = product.description {
                    Text(description)
                        .font(.caption)
                }

                Text(product.getDisplayName(.brandOwner))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .if(extras.contains(.companyLink), transform: { view in
                        view.contentShape(Rectangle())
                            .accessibilityAddTraits(.isLink)
                            .onTapGesture {
                                router.navigate(screen: .company(product.subBrand.brand.brandOwner))
                            }
                    })

                HStack {
                    CategoryView(category: product.category, subcategories: product.subcategories)
                    Spacer()
                    if let averageRating = product.averageRating, extras.contains(.rating) {
                        RatingView(rating: averageRating, type: .small)
                    }
                }
            }
        }
    }
}
