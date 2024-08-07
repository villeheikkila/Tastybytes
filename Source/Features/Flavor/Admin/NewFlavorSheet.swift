import Components
import SwiftUI

struct NewFlavorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    let onSubmit: (_ name: String) async -> Void

    var body: some View {
        Form {
            TextField("flavor.name.placeholder", text: $name)
            AsyncButton("labels.add", action: { [name] in
                await onSubmit(name)
                dismiss()
            })
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("flavor.add.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
