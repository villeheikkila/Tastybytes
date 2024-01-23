import SwiftUI

public struct ToolbarDismissAction: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            CloseButtonView {
                dismiss()
            }
        }
    }
}
