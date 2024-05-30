import SwiftUI

extension View {
    func fullScreenCovers(item: Binding<FullScreenCover?>) -> some View {
        modifier(FullScreenCoverModifier(item: item))
    }
}

struct FullScreenCoverModifier: ViewModifier {
    @Binding var item: FullScreenCover?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $item) { item in
                NavigationStack {
                    item.view
                }
            }
    }
}
