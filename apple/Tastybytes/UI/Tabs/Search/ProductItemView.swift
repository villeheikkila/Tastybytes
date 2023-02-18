import SwiftUI

struct ProductItemView: View {
  let product: Product.Joined

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack {
        Text(product.getDisplayName(.fullName))
          .font(.system(size: 16, weight: .bold, design: .default))
        Spacer()
        if let currentUserCheckIns = product.currentUserCheckIns, currentUserCheckIns > 0 {
          Image(systemName: "checkmark")
        }
      }
      if let description = product.description {
        Text(description)
          .font(.system(size: 12, weight: .medium, design: .default))
      }

      Text(product.getDisplayName(.brandOwner))
        .font(.system(size: 14, weight: .bold, design: .default))
        .foregroundColor(.secondary)

      HStack {
        CategoryNameView(category: product.category)
        ForEach(product.subcategories, id: \.id) { subcategory in
          ChipView(title: subcategory.name, cornerRadius: 5)
        }
        Spacer()
        if let averageRating = product.averageRating {
          RatingView(rating: averageRating, type: .small)
        }
      }
    }
  }
}
