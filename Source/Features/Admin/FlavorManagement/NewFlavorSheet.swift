import Components
import SwiftUI

@MainActor
struct NewFlavorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    let onSubmit: (_ name: String) async -> Void

    var body: some View {
        Form {
            TextField("flavor.name.placeholder", text: $name)
            ProgressButton("labels.add", action: {
                await onSubmit(name)
                await MainActor.run {
                    dismiss()
                }
            })
        }
        .navigationTitle("flavor.add.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
