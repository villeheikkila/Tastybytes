import Models
import SwiftUI

@MainActor
public struct SubcategoryLabelView: View {
    let subcategory: SubcategoryProtocol

    public init(subcategory: SubcategoryProtocol) {
        self.subcategory = subcategory
    }

    public var body: some View {
        Text(subcategory.name)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(Color(seed: subcategory.name))
            .clipShape(.capsule)
    }
}

#Preview {
    VStack {
        CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
        SubcategoryLabelView(subcategory: Subcategory(id: 0, name: "BCAA", isVerified: true))
    }
}
