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
            .font(.caption)
            .fontWeight(.bold)
            .padding(4)
            .foregroundColor(.white)
        #if !os(watchOS)
            .background(Color(.systemBlue))
        #endif
            .cornerRadius(6)
    }
}

#Preview {
    VStack {
        CategoryNameView(category: Category(id: 0, name: "beverage", icon: "🥤"))
        SubcategoryLabelView(subcategory: Subcategory(id: 0, name: "BCAA", isVerified: true))
    }
}
