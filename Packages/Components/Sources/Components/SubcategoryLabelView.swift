import Models
import SwiftUI

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
            .clipShape(.rect(cornerRadius: 4))
    }
}

#Preview {
    VStack {
        CategoryNameView(category: Category.Saved(id: 0, name: "beverage", icon: "🥤"))
        SubcategoryLabelView(subcategory: Subcategory.Saved(id: 0, name: "BCAA", isVerified: true))
    }
}
