import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var newCategoryName = ""

    let onSubmit: (_ newCategoryName: String) async -> Void

    var body: some View {
        Form {
            TextField("category.name.placeholder", text: $newCategoryName)
            ProgressButton("labels.add", action: {
                await appEnvironmentModel.addCategory(name: newCategoryName)
                await MainActor.run {
                    dismiss()
                }
            }).disabled(newCategoryName.isEmpty)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("category.add.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
