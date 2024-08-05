import Models
import SwiftUI

struct FlavorView: View {
    @Environment(\.flavorStyle) private var flavorStyle
    let flavor: Flavor.Saved

    var body: some View {
        switch flavorStyle {
        case .plain:
            Text(flavor.label)
        case .chip:
            ChipView(title: flavor.label)
        }
    }
}

enum FlavorStyle {
    case plain, chip
}

extension EnvironmentValues {
    @Entry var flavorStyle: FlavorStyle = .plain
}

extension View {
    func flavorStyle(_ style: FlavorStyle) -> some View {
        environment(\.flavorStyle, style)
    }
}
