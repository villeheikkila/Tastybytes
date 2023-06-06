import SwiftUI

struct CategoryView: View {
  let category: Category
  let subcategories: [SubcategoryProtocol]
  let servingStyle: ServingStyle?

  init(category: Category, subcategories: [SubcategoryProtocol], servingStyle: ServingStyle? = nil) {
    self.category = category
    self.subcategories = subcategories
    self.servingStyle = servingStyle
  }

  var body: some View {
    HStack(spacing: 4) {
      CategoryNameView(category: category)
      ForEach(subcategories, id: \.name) { subcategory in
        SubcategoryLabelView(subcategory: subcategory)
      }
      if let servingStyle {
        ServingStyleLabelView(servingStyle: servingStyle)
      }
    }
  }
}

#Preview {
    CategoryView(
      category: Category(id: 0, name: "beverage", icon: "🥤"),
      subcategories: [Subcategory(id: 0, name: "BCAA", isVerified: true)]
    )
  }
