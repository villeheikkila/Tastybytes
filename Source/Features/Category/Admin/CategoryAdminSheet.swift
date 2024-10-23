import Components

import Logging
import Models
import Repositories
import SwiftUI

struct CategoryAdminSheet: View {
    private let logger = Logger(label: "CategoryAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var category = Models.Category.Detailed()

    let id: Models.Category.Id

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: category)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .navigationTitle("category.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        Section("category.admin.section.category") {
            CategoryView(category: category)
        }
        .customListRowBackground()

        ModificationInfoView(modificationInfo: category)

        if !category.subcategories.isEmpty {
            Section("category.admin.section.subcategory") {
                ForEach(category.subcategories) { subcategory in
                    CategoryAdminSheetSubcategoryRowView(subcategory: subcategory)
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
                    await appModel.addSubcategory(category: .init(category: category), name: newSubcategoryName)
                }))
            )
        }
        .customListRowBackground()

        Section {
            ConfirmedDeleteButtonView(presenting: category, action: { _ in
                await appModel.deleteCategory(.init(category: category), onDelete: {
                    dismiss()
                })
            }, description: "category.admin.delete.confirmationDialog.title", label: "category.admin.delete.confirmationDialog.label \(category.name)", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func initialize() async {
        do {
            category = try await repository.category.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed category info. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CategoryAdminSheetSubcategoryRowView: View {
    let subcategory: SubcategoryProtocol

    var body: some View {
        RouterLink(open: .sheet(.subcategoryAdmin(id: subcategory.id, onEdit: { subcategoryName in
            print(subcategoryName)
        }))) {
            SubcategoryView(subcategory: subcategory)
        }
    }
}
