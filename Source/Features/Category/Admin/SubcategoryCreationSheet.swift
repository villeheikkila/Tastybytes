import Components
import Models
import SwiftUI

struct SubcategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newSubcategoryName = ""
    let category: CategoryProtocol
    let onSubmit: (_ newSubcategoryName: String) async -> Void

    var body: some View {
        Form {
            Section("subcategory.addTo.category.title") {
                TextField("subcategory.name.placeholder", text: $newSubcategoryName)
                AsyncButton("labels.add", action: { [newSubcategoryName] in
                    await onSubmit(newSubcategoryName)
                    dismiss()
                }).disabled(newSubcategoryName.isEmpty)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("subcategory.addTo.category.navigationTitle \(category.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
