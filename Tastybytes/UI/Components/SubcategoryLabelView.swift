import Model
import SwiftUI

struct SubcategoryLabelView: View {
    let subcategory: SubcategoryProtocol

    var body: some View {
        Text(subcategory.name)
            .font(.caption)
            .fontWeight(.bold)
            .padding(4)
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .cornerRadius(6)
    }
}

#Preview {
    VStack {
        CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
        SubcategoryLabelView(subcategory: Subcategory(id: 0, name: "BCAA", isVerified: true))
    }
}
