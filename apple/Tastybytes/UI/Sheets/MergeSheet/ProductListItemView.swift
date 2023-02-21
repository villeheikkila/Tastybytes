import SwiftUI

struct ProductListItemView: View {
  let product: Product.Joined

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(product.getDisplayName(.fullName))
        .font(.headline)
        .foregroundColor(.primary)

      Text(product.getDisplayName(.brandOwner))
        .font(.subheadline)
        .foregroundColor(.secondary)

      CategoryView(category: product.category, subcategories: product.subcategories)
    }
  }
}
