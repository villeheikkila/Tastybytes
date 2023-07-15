import SwiftUI

struct CloseButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemSymbol: .xmark)
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
