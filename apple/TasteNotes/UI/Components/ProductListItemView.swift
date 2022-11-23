import SwiftUI

struct ProductListItemView: View {
    let product: Product.Joined

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(product.getDisplayName(.fullName))
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.primary)

            Text(product.getDisplayName(.brandOwner))
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.secondary)
            
            HStack {
                Text(product.category.name.rawValue.capitalized).font(.system(size: 12, weight: .bold, design: .default))
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name, cornerRadius: 5)
                }
            }
        }
    }
}
