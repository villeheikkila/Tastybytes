import SwiftUI

extension View {
    func sheets(item: Binding<Sheet?>) -> some View {
        modifier(SheetsModifier(item: item))
    }
}

struct SheetsModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Binding var item: Sheet?

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                RouterProvider {
                    item.view
                }
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .presentationBackground(colorScheme == .dark ? item.backgroundDark : item.backgroundLight)
                .presentationDetents(item.detents)
                .presentationCornerRadius(item.cornerRadius)
                .presentationDragIndicator(.hidden)
                .presentationSizing(.form)
                .environment(\.isPresentedInSheet, true)
            }
    }
}
