import SwiftUI

struct AddSubcategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newSubcategoryName = ""
    let category: CategoryProtocol
    let onSubmit: (_ newSubcategoryName: String) async -> Void

    var body: some View {
        Form {
            Section("Add Subcategory") {
                TextField("Name", text: $newSubcategoryName)
                ProgressButton("Add", action: {
                    await onSubmit(newSubcategoryName)
                    dismiss()
                }).disabled(newSubcategoryName.isEmpty)
            }
            .navigationTitle("Add subcategory to \(category.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }
}
