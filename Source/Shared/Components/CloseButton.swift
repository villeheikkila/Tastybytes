import SwiftUI

@MainActor
public struct CloseButton: View {
    @State private var isPressed = false
    let action: @MainActor () -> Void

    public var body: some View {
        Button(action: {
            isPressed = true
        }, label: {
            Circle()
                .fill(.ultraThickMaterial)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                )
        })
        .buttonStyle(.plain)
        .symbolEffect(.bounce.down, value: isPressed)
        .task(id: isPressed) {
            guard isPressed else { return }
            do { try await Task.sleep(for: .milliseconds(100)) } catch {}
            action()
        }
        .accessibilityLabel("labels.close")
    }
}

#Preview {
    CloseButton(action: {})
}
