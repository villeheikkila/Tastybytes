import SwiftUI

enum CardStyleType {
    case `default`

    var cornerRadius: CGFloat {
        switch self {
        case .default:
            16
        }
    }
}

struct CardStyle: ViewModifier {
    @Environment(\.isPresentedInSheet) private var isPresentedInSheet
    @Environment(\.colorScheme) private var colorScheme

    let type: CardStyleType

    init(_ type: CardStyleType = .default) {
        self.type = type
    }

    private var color: Color {
        switch colorScheme {
        case .light:
            Color(uiColor: .systemGroupedBackground)
        case .dark:
            .black
        @unknown default:
            .white
        }
    }

    func body(content: Content) -> some View {
        content
            .background(color.opacity(colorScheme == .dark ? 0.3 : 1))
            .clipShape(.rect(cornerRadius: type.cornerRadius))
            .shadow(
                color: .black.opacity(0.1),
                radius: 2,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func cardStyle(_ type: CardStyleType = .default) -> some View {
        modifier(CardStyle(type))
    }
}
