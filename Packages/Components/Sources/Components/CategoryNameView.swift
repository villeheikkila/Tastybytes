import Models
import SwiftUI

public struct CategoryNameView: View {
    let category: CategoryProtocol
    let withBorder: Bool

    public init(category: CategoryProtocol, withBorder: Bool = true) {
        self.category = category
        self.withBorder = withBorder
    }

    public var body: some View {
        HStack {
            Group {
                if let icon = category.icon {
                    Text(icon)
                        .grayscale(1)
                }
                Text(category.name)
            }
            .font(.caption)
            .bold()
        }
        .if(withBorder, transform: { view in
            view
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(lineWidth: 1)
                )
        })
    }
}

#Preview {
    CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
}
