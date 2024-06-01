import SwiftUI

struct ListRowBackgroundModifier: ViewModifier {
    @Environment(\.isPresentedInSheet) var isPresentedInSheet
    @Environment(\.colorScheme) private var colorScheme

    var color: Color {
        switch colorScheme {
        case .light:
            .white
        case .dark:
            .black
        @unknown default:
            .white
        }
    }

    func body(content: Content) -> some View {
        content
            .listRowBackground(color.opacity(isPresentedInSheet ? 0.3 : 1))
    }
}

extension View {
    func customListRowBackground() -> some View {
        modifier(ListRowBackgroundModifier())
    }
}
