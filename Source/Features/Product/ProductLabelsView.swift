import Components
import Models
import SwiftUI

struct ProductLabelsView: View {
    let category: Models.Category.Saved
    let subcategories: [SubcategoryProtocol]
    let servingStyle: ServingStyle.Saved?

    init(category: Models.Category.Saved, subcategories: [SubcategoryProtocol], servingStyle: ServingStyle.Saved? = nil) {
        self.category = category
        self.subcategories = subcategories
        self.servingStyle = servingStyle
    }

    public var body: some View {
        WStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
            CategoryView(category: category)
            ForEach(subcategories, id: \.id) { subcategory in
                SubcategoryView(subcategory: subcategory)
            }
            if let servingStyle {
                ServingStyleView(servingStyle: servingStyle)
            }
        }
        .categoryStyle(.chip)
        .subcategoryStyle(.chip)
        .servingStyle(.chip)
    }
}

#Preview {
    ProductLabelsView(
        category: .init(id: 0, name: "beverage", icon: "🥤"),
        subcategories: [Subcategory.Saved(id: 0, name: "BCAA", isVerified: true)],
        servingStyle: .init(
            id: 1,
            name: "Can"
        )
    )
}
