import Components
import Models
import SwiftUI

@MainActor
struct AddSubcategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newSubcategoryName = ""
    let category: CategoryProtocol
    let onSubmit: (_ newSubcategoryName: String) async -> Void

    var body: some View {
        Form {
            Section("subcategory.addTo.category.title") {
                TextField("subcategory.name.placeholder", text: $newSubcategoryName)
                ProgressButton("labels.add", action: {
                    await onSubmit(newSubcategoryName)
                    await MainActor.run {
                        dismiss()
                    }
                }).disabled(newSubcategoryName.isEmpty)
            }
        }
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
