import SwiftUI

public struct ToolbarDoneAction: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some ToolbarContent {
        ToolbarItemGroup(placement: .confirmationAction) {
            Button("Done", action: { dismiss() })
        }
    }
}
