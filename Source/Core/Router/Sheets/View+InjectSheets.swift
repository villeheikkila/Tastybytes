import SwiftUI

extension View {
    func injectSheets(item: Binding<Sheet?>) -> some View {
        modifier(InjectSheetsModifier(item: item))
    }
}

struct InjectSheetsModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var item: Sheet?

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                RouterProvider(enableRoutingFromURLs: false) {
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
