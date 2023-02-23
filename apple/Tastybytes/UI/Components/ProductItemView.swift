import SwiftUI

struct ProductItemView: View {
  @EnvironmentObject private var router: Router
  enum Extra {
    case checkInCheck, rating, companyLink
  }

  let product: Product.Joined
  let extras: [Extra]

  init(product: Product.Joined, extras: [Extra] = []) {
    self.product = product
    self.extras = extras
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack {
        Text(product.getDisplayName(.fullName))
          .font(.headline)
        Spacer()
        if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0,
           extras.contains(.checkInCheck)
        {
          Image(systemName: "checkmark.circle")
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
              router.navigate(to: .company(product.subBrand.brand.brandOwner), resetStack: false)
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
