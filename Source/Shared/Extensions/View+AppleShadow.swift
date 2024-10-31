import SwiftUI

struct AppleShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
            .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
    }
}

extension View {
    func appleShadow() -> some View {
        modifier(AppleShadow())
    }
}
