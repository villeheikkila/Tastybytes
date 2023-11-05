import SwiftUI

public struct CloseButtonView: View {
    @State private var isPressed = false
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            isPressed = true
        }, label: {
            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                )
        })
        .buttonStyle(PlainButtonStyle())
        .symbolEffect(.bounce.down, value: isPressed)
        .onChange(of: isPressed) {
            Task {
                try await Task.sleep(for: .milliseconds(200))
                action()
            }
        }
        .accessibilityLabel("Close")
    }
}

#Preview {
    CloseButtonView(action: {})
}

