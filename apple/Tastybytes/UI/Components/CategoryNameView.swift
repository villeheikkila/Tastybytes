import SwiftUI

struct CategoryNameView: View {
  let category: CategoryProtocol
  let withBorder: Bool

  init(category: CategoryProtocol, withBorder: Bool = true) {
    self.category = category
    self.withBorder = withBorder
  }

  var body: some View {
    HStack {
      Group {
        Text(category.icon)
          .grayscale(1)
        Text(category.name)
      }
      .font(.caption)
      .bold()
    }
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

#Preview {
    CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
}
