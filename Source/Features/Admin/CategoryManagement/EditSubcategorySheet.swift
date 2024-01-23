import Components
import Models
import SwiftUI

struct EditSubcategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subcategoryName = ""
    let subcategory: Subcategory
    let onSubmit: (_ subcategoryName: String) async -> Void

    init(subcategory: Subcategory, onSubmit: @escaping (_ subcategoryName: String) async -> Void) {
        _subcategoryName = State(wrappedValue: subcategory.name)
        self.subcategory = subcategory
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            TextField("Name", text: $subcategoryName)
            ProgressButton("Save changes", action: {
                await onSubmit(subcategoryName)
                await MainActor.run {
                    dismiss()
                }
            }).disabled(subcategoryName.isEmpty || subcategory.name == subcategoryName)
        }
        .navigationTitle("Edit \(subcategory.name)")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
