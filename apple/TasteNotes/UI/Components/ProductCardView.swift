import SwiftUI

struct ProductCardView: View {
    let product: Product.Joined

    var body: some View {
        VStack {
            HStack {
                CategoryNameView(category: product.category)
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name, cornerRadius: 5)
                }
            }

            Text(product.getDisplayName(.fullName))
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.primary)
            HStack {
                NavigationLink(value: product.subBrand.brand.brandOwner) {
                    Text(product.getDisplayName(.brandOwner))
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.all, 10)
        .cornerRadius(5)
    }
}
