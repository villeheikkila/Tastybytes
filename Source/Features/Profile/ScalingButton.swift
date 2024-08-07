import SwiftUI

struct ScalingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 10)
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(.rect)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScalingButtonStyle {
    static var scalingButton: ScalingButtonStyle { .init() }
}
