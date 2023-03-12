import SwiftUI

struct CategoryView: View {
  let category: Category
  let subcategories: [SubcategoryProtocol]

  var body: some View {
    HStack(spacing: 4) {
      CategoryNameView(category: category)
      ForEach(subcategories, id: \.name) { subcategory in
        ChipView(title: subcategory.label)
      }
    }
  }
}
