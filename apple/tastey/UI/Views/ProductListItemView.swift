import SwiftUI

struct ProductListItemView: View {
    let product: ProductJoined
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let categoryName = product.getCategory() {
                Text(categoryName.rawValue.capitalized).font(.system(size: 12, weight: .bold, design: .default))
            }
            Text(product.getDisplayName(.fullName))
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.primary)
            
            Text(product.getDisplayName(.brandOwner))
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name, cornerRadius: 5)
                }
            }
        }
    }
}
