import SwiftUI

public struct CloseButtonView: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action()
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
        .accessibilityLabel("Close")
    }
}

#Preview {
    CloseButtonView(action: {})
}
