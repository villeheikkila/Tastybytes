import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack {
            HStack {
            if let categoryName = product.getCategory() {
                Text(categoryName.rawValue.capitalized).font(.system(size: 12, weight: .bold, design: .default))
            }
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name, cornerRadius: 5)
                }
            }

            Text(product.getDisplayName(.fullName))
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.primary)
            HStack {
                Text(product.getDisplayName(.brandOwner))
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .cornerRadius(5)
    }
}
