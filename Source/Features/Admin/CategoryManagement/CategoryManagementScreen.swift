import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

@MainActor
struct CategoryManagementScreen: View {
    private let logger = Logger(category: "CategoryManagementScreen")
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var verifySubcategory: Subcategory?
    @State private var sheet: Sheet?
    @State private var deleteSubcategory: Subcategory?

    var body: some View {
        List(appEnvironmentModel.categories) { category in
            Section {
                ForEach(category.subcategories) { subcategory in
                    HStack {
                        Text(subcategory.name)
                    }
                }
            } header: {
                HStack {
                    Text(category.name)
                    Spacer()
                    Menu {
                        Button(
                            "servingStyle.edit.menu.label",
                            systemImage: "pencil",
                            action: { sheet = .categoryServingStyle(category: category) }
                        )
                        Button(
                            "subcategory.add",
                            systemImage: "plus",
                            action: { sheet = .addSubcategory(category: category, onSubmit: { newSubcategoryName in
                                await appEnvironmentModel.addSubcategory(
                                    category: category,
                                    name: newSubcategoryName
                                )
                            }) }
                        )
                    } label: {
                        Label("labels.menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    }
                    .sheets(item: $sheet)
                }
            }
            .headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await appEnvironmentModel.initialize(reset: true)
        }
        .navigationBarTitle("category.title")
        .toolbar {
            toolbarContent
        }
        .confirmationDialog("subcategory.delete.confirmation.description",
                            isPresented: $deleteSubcategory.isNotNull(),
                            titleVisibility: .visible,
                            presenting: deleteSubcategory)
        { presenting in
            ProgressButton(
                "subcategory.delete.confirmation.label \(presenting.name)",
                role: .destructive,
                action: { await appEnvironmentModel.deleteSubcategory(presenting) }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(
                "category.add.label",
                systemImage: "plus",
                action: { sheet = .addCategory(onSubmit: { _ in
                    feedbackEnvironmentModel.toggle(.success("category.add.success.toast"))
                }) }
            )
            .labelStyle(.iconOnly)
            .bold()
        }
    }
}
