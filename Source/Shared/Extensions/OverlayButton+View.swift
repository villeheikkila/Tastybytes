import SwiftUI

struct OverlayDeleteButtonModifier: ViewModifier {
    @State private var submitting = false
    var action: () async -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Label("labels.delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .imageScale(.small)
                    .tint(.red)
                    .padding(3)
                    .foregroundColor(.red)
                    .background(.ultraThinMaterial, in: .circle)
            }
            .padding(4)
            .onTapGesture {
                guard submitting == false else { return }
                Task {
                    submitting = true
                    await action()
                    submitting = false
                }
            }
    }
}

extension View {
    func overlayDeleteButton(action: @escaping () async -> Void) -> some View {
        modifier(OverlayDeleteButtonModifier(action: action))
    }
}
