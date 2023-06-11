import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppDataManager.self) private var appDataManager
    @State private var newCategoryName = ""

    let onSubmit: (_ newCategoryName: String) async -> Void

    var body: some View {
        Form {
            TextField("Name", text: $newCategoryName)
            ProgressButton("Add", action: {
                await appDataManager.addCategory(name: newCategoryName)
                dismiss()
            }).disabled(newCategoryName.isEmpty)
        }
        .navigationTitle("Add Category")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }
}
