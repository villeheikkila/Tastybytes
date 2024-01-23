import Components
import SwiftUI

struct NewFlavorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    let onSubmit: (_ name: String) async -> Void

    var body: some View {
        Form {
            TextField("Name", text: $name)
            ProgressButton("Add", action: {
                await onSubmit(name)
                await MainActor.run {
                    dismiss()
                }
            })
        }
        .navigationTitle("Add Flavor")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
