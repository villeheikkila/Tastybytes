import SwiftUI

struct ListRowBackgroundModifier: ViewModifier {
    @Environment(\.isPresentedInSheet) private var isPresentedInSheet
    @Environment(\.colorScheme) private var colorScheme

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
            .if(isPresentedInSheet) { view in
                view.listRowBackground(color.opacity(colorScheme == .dark ? 0.3 : 1))
            }
    }
}

extension View {
    func customListRowBackground() -> some View {
        modifier(ListRowBackgroundModifier())
    }
}
