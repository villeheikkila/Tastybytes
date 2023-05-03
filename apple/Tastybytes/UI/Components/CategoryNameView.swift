import SwiftUI

struct CategoryNameView: View {
  let category: CategoryProtocol
  let withBorder: Bool

  init(category: CategoryProtocol, withBorder: Bool = true) {
    self.category = category
    self.withBorder = withBorder
  }

  var body: some View {
    Text(category.label)
      .font(.caption)
      .bold()
      .grayscale(1)
      .if(withBorder, transform: { view in
        view
          .padding(4)
          .overlay(
            RoundedRectangle(cornerRadius: 6)
              .stroke(lineWidth: 1)
          )
      })
  }
}

struct CategoryNameView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
  }
}
