import SwiftUI

struct Snack: Identifiable, Equatable {
    enum Mode {
        case snack(tint: Color, systemName: String, message: LocalizedStringKey)
        case hud(systemName: String, foregroundColor: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey?)
    }

    let id: UUID
    let mode: Mode
    var offsetX: CGFloat = 0
    var isDeleting: Bool = false

    init(mode: Mode) {
        id = UUID()
        self.mode = mode
    }

    static func == (lhs: Snack, rhs: Snack) -> Bool {
        lhs.id == rhs.id && lhs.isDeleting == rhs.isDeleting
    }

    @MainActor
    @ViewBuilder
    var view: some View {
        switch mode {
        case let .snack(tint, systemName, message):
            SnackView(id: id, tint: tint, systemName: systemName, message: message)
        case let .hud(systemName, foregroundColor, title, subtitle):
            HUDView(
                systemName: systemName,
                foregroundColor: foregroundColor,
                title: title,
                subtitle: subtitle
            )
        }
    }
}
