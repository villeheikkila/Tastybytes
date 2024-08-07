import Models
import SwiftUI

struct CategoryView: View {
    @Environment(\.categoryStyle) private var categoryStyle
    let category: CategoryProtocol

    var body: some View {
        HStack {
            Group {
                if let icon = category.icon {
                    Text(icon)
                        .grayscale(1)
                }
                Text(category.name)
            }
            .bold()
        }
        .if(categoryStyle == .chip, transform: { view in
            view
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(lineWidth: 1)
                )
        })
    }
}

enum CategoryStyle {
    case plain, chip
}

extension EnvironmentValues {
    @Entry var categoryStyle: CategoryStyle = .plain
}

extension View {
    func categoryStyle(_ style: CategoryStyle) -> some View {
        environment(\.categoryStyle, style)
    }
}
