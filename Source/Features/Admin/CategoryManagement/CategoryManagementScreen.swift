import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

struct CategoryManagementScreen: View {
    private let logger = Logger(category: "CategoryManagementScreen")
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Router.self) private var router

    var body: some View {
        List(appEnvironmentModel.categories) { category in
            CategoryManagementRow(category: category)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await appEnvironmentModel.initialize(reset: true)
        }
        .navigationBarTitle("category.title")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(
                "category.add.label",
                systemImage: "plus",
                action: { router.openSheet(.addCategory(onSubmit: { _ in
                    feedbackEnvironmentModel.toggle(.success("category.add.success.toast"))
                })) }
            )
            .labelStyle(.iconOnly)
            .bold()
        }
    }
}

struct CategoryManagementRow: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Router.self) private var router

    let category: Models.Category.JoinedSubcategoriesServingStyles

    var body: some View {
        Section {
            ForEach(category.subcategories) { subcategory in
                CategoryManagementSubcategoryRow(subcategory: subcategory)
            }
        } header: {
            HStack {
                Text(category.name)
                Spacer()
                Menu {
                    Button(
                        "servingStyle.edit.menu.label",
                        systemImage: "pencil",
                        action: { router.openSheet(.categoryServingStyle(category: category)) }
                    )
                    Button(
                        "subcategory.add",
                        systemImage: "plus",
                        action: { router.openSheet(.addSubcategory(category: category, onSubmit: { newSubcategoryName in
                            await appEnvironmentModel.addSubcategory(
                                category: category,
                                name: newSubcategoryName
                            )
                        })) }
                    )
                } label: {
                    Label("labels.menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .headerProminence(.increased)
    }
}

struct CategoryManagementSubcategoryRow: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var showDeleteConfirmationDialog = false

    let subcategory: Subcategory

    var body: some View {
        Text(subcategory.name)
            .contextMenu {
                Button(
                    "labels.delete",
                    systemImage: "trash",
                    role: .destructive,
                    action: { showDeleteConfirmationDialog = true }
                )
            }
            .confirmationDialog("subcategory.delete.confirmation.description",
                                isPresented: $showDeleteConfirmationDialog,
                                titleVisibility: .visible,
                                presenting: subcategory)
        { presenting in
            ProgressButton(
                "subcategory.delete.confirmation.label \(presenting.name)",
                role: .destructive,
                action: { await appEnvironmentModel.deleteSubcategory(presenting) }
            )
        }
    }
}
