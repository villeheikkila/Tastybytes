import SwiftUI

public struct ToolbarDoneActionView: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some ToolbarContent {
        ToolbarItemGroup(placement: .confirmationAction) {
            Button("labels.done", action: { dismiss() })
        }
    }
}
