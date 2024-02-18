import SwiftUI

struct ToolbarDismissAction: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            CloseButton {
                dismiss()
            }
        }
    }
}
