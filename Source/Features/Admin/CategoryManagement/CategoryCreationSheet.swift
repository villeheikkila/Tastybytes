import Components
import EnvironmentModels
import SwiftUI

struct CategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var newCategoryName = ""

    let onSubmit: (_ newCategoryName: String) async -> Void

    var body: some View {
        Form {
            Section("category.name.placeholder") {
                TextField("category.name.placeholder", text: $newCategoryName)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("category.add.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            ProgressButton("labels.add", action: {
                await appEnvironmentModel.addCategory(name: newCategoryName)
                dismiss()
            }).disabled(newCategoryName.isEmpty)
        }
    }
}
