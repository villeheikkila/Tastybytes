import Models
import SwiftUI

public struct SubcategoryView: View {
    @Environment(\.subcategoryStyle) private var subcategoryStyle
    let subcategory: SubcategoryProtocol

    public init(subcategory: SubcategoryProtocol) {
        self.subcategory = subcategory
    }

    public var body: some View {
        switch subcategoryStyle {
        case .plain:
            Text(subcategory.name)
        case .chip:
            Text(subcategory.name)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(Color(seed: subcategory.name))
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

enum SubcategoryStyle {
    case plain, chip
}

extension EnvironmentValues {
    @Entry var subcategoryStyle: SubcategoryStyle = .plain
}

extension View {
    func subcategoryStyle(_ style: SubcategoryStyle) -> some View {
        environment(\.subcategoryStyle, style)
    }
}
