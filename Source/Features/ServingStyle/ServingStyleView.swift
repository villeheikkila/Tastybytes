import Models
import SwiftUI

struct ServingStyleView: View {
    @Environment(\.servingStyle) private var servingStyleStyle
    let servingStyle: ServingStyle.Saved

    var body: some View {
        switch servingStyleStyle {
        case .plain:
            Text(servingStyle.label)
        case .chip:
            Text(servingStyle.label)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(.white)
                .background(.gray)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

enum ServingStyleStyle {
    case plain, chip
}

extension EnvironmentValues {
    @Entry var servingStyle: ServingStyleStyle = .plain
}

extension View {
    func servingStyle(_ style: ServingStyleStyle) -> some View {
        environment(\.servingStyle, style)
    }
}
