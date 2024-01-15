import SwiftUI

extension View {
    func sheets(item: Binding<Sheet?>) -> some View {
        modifier(SheetsModifier(item: item))
    }
}

struct SheetsModifier: ViewModifier {
    @Binding var item: Sheet?

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                NavigationStack {
                    item.view
                }
                .presentationBackground(Material.ultraThin)
                .presentationDetents(item.detents)
                .presentationCornerRadius(item.cornerRadius)
                .presentationDragIndicator(.visible)
            }
    }
}
