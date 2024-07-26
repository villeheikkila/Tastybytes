import Components

import SwiftUI

struct CategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppModel.self) private var appModel
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
            AsyncButton("labels.add", action: {
                await appModel.addCategory(name: newCategoryName)
                dismiss()
            }).disabled(newCategoryName.isEmpty)
        }
    }
}
