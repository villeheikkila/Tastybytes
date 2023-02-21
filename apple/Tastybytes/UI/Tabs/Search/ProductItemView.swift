import SwiftUI

struct ProductItemView: View {
  let product: Product.Joined

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack {
        Text(product.getDisplayName(.fullName))
          .font(.headline)
        Spacer()
        if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0 {
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

      HStack {
        CategoryView(category: product.category, subcategories: product.subcategories)
        Spacer()
        if let averageRating = product.averageRating {
          RatingView(rating: averageRating, type: .small)
        }
      }
    }
  }
}
