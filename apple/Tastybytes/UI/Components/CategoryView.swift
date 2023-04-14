import SwiftUI

struct CategoryView: View {
  let category: Category
  let subcategories: [SubcategoryProtocol]

  var body: some View {
    HStack(spacing: 4) {
      CategoryNameView(category: category)
      ForEach(subcategories, id: \.name) { subcategory in
        SubcategoryLabelView(subcategory: subcategory)
      }
    }
  }
}

struct CategoryView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryView(
      category: Category(id: 0, name: "beverage", icon: "🥤"),
      subcategories: [Subcategory(id: 0, name: "BCAA", isVerified: true)]
    )
  }
}
