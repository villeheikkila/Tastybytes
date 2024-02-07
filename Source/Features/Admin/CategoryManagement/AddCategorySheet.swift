import Components
import EnvironmentModels
import SwiftUI

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
        .navigationTitle("category.add.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
