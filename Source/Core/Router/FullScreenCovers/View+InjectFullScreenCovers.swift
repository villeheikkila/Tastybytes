import SwiftUI

extension View {
    func injectFullScreenCovers(item: Binding<FullScreenCover?>) -> some View {
        modifier(InjectFullScreenCoversModifier(item: item))
    }
}

struct InjectFullScreenCoversModifier: ViewModifier {
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
