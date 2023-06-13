import SwiftUI

struct ProductItemView: View {
    @Environment(Router.self) private var router
    enum Extra {
        case checkInCheck, rating, companyLink, logo
    }

    let product: Product.Joined
    let extras: [Extra]

    init(product: Product.Joined, extras: [Extra] = []) {
        self.product = product
        self.extras = extras
    }

    var body: some View {
        HStack(spacing: 24) {
            if extras.contains(.logo), let logoUrl = product.logoUrl {
                AsyncImage(url: logoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 68, height: 68)
                        .accessibility(hidden: true)
                } placeholder: {
                    ProgressView()
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.getDisplayName(.fullName))
                        .font(.headline)
                    Spacer()
                    if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0,
                       extras.contains(.checkInCheck)
                    {
                        Label("Checked-in", systemSymbol: .checkmarkCircle)
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
