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
    @State private var state: ScreenState = .loading
    @State private var category: Models.Category.Detailed?

    let id: Int

    init(category: CategoryProtocol) {
        id = category.id
    }

    var body: some View {
        Form {
            if let category {
                content(category: category)
            }
        }
        .scrollContentBackground(.hidden)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await load()
            }
        }
        .navigationTitle("category.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await load()
        }
    }

    @ViewBuilder private func content(category: Models.Category.Detailed) -> some View {
        Section("category.admin.section.category") {
            CategoryNameView(category: category)
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
                    await appEnvironmentModel.addSubcategory(category: .init(category: category), name: newSubcategoryName)
                }))
            )
        }
        .customListRowBackground()

        Section {
            ConfirmedDeleteButtonView(presenting: category, action: { _ in
                await appEnvironmentModel.deleteCategory(.init(category: category), onDelete: {
                    dismiss()
                })
            }, description: "category.admin.delete.confirmationDialog.title", label: "category.admin.delete.confirmationDialog.label \(category.name)", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func load() async {
        do {
            category = try await repository.category.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed category info. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CategoryAdminSheetSubcategoryRowView: View {
    let subcategory: SubcategoryProtocol

    var body: some View {
        RouterLink(open: .sheet(.subcategoryAdmin(subcategory: subcategory, onSubmit: { subcategoryName in
            print(subcategoryName)
        }))) {
            Text(subcategory.name)
        }
    }
}
