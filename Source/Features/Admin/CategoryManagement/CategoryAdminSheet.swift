import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CategoryAdminSheet: View {
    private let logger = Logger(category: "CategoryAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    let category: Models.Category.JoinedSubcategoriesServingStyles

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("category.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
        Section("category.admin.section.category") {
            CategoryNameView(category: category)
        }
        .customListRowBackground()

        if !category.subcategories.isEmpty {
            Section("category.admin.section.subcategory") {
                ForEach(category.subcategories) { subcategory in
                    CategoryAdminSheetSubcategoryRow(subcategory: .init(category: .init(category: category), subcategory: subcategory))
                }
            }
            .customListRowBackground()
        }

        Section {
            RouterLink(
                "servingStyle.edit.menu.label",
                systemImage: "pencil",
                open: .screen(.categoryServingStyle(category: category))
            )
            RouterLink(
                "subcategory.add",
                systemImage: "plus",
                open: .sheet(.subcategoryCreation(category: category, onSubmit: { newSubcategoryName in
                    await appEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
                }))
            )
        }
        .customListRowBackground()

        Section {
            ConfirmedDeleteButtonView(presenting: category, action: { preseting in
                await appEnvironmentModel.deleteCategory(preseting, onDelete: {
                    dismiss()
                })
            }, description: "category.admin.delete.confirmationDialog.title", label: "category.admin.delete.confirmationDialog.label \(category.name)", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}

struct CategoryAdminSheetSubcategoryRow: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var showDeleteConfirmationDialog = false

    let subcategory: Subcategory.JoinedCategory

    var body: some View {
        RouterLink(open: .sheet(.subcategoryAdmin(subcategory: subcategory, onSubmit: { subcategoryName in
            print(subcategoryName)
        }))) {
            Text(subcategory.name)
        }
    }
}
