import SwiftUI

struct Snack: Identifiable {
    enum Mode {
        case snack(tint: Color, systemName: String, message: LocalizedStringKey)
        case hud(systemName: String, foregroundColor: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey?)
    }

    let id: UUID
    let mode: Mode
    let timeout: TimeInterval?
    let onRetry: (() async -> Void)?
    var isDeleting: Bool = false

    init(mode: Mode, timeout: TimeInterval? = nil, onRetry: (() async -> Void)? = nil) {
        id = UUID()
        self.mode = mode
        self.timeout = timeout
        self.onRetry = onRetry
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
