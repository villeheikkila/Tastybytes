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
            TextField("Name", text: $newCategoryName)
            ProgressButton("Add", action: {
                await appEnvironmentModel.addCategory(name: newCategoryName)
                await MainActor.run {
                    dismiss()
                }
            }).disabled(newCategoryName.isEmpty)
        }
        .navigationTitle("Add Category")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("actions.cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }
}
