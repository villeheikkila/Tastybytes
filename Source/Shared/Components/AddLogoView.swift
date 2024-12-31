import SwiftUI

struct AddLogoView: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
            action()
        }) {
            Image(systemName: "photo")
                .frame(width: 64, height: 64)
                .foregroundColor(.gray)
                .background(.gray.secondary.opacity(0.2))
                .clipShape(.rect(cornerRadius: 8))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.blue, in: .circle)
                        .offset(x: 6, y: 6)
                        .scaleEffect(isPressed ? 0.92 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                }
                .scaleEffect(isPressed ? 0.92 : 1)
                .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("logos.addLogo")
    }
}

#Preview {
    AddLogoView {}
}
