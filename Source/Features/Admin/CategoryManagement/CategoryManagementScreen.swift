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
    @State private var showDeleteSubcategoryConfirmation = false
    @State private var verifySubcategory: Subcategory?
    @State private var sheet: Sheet?
    @State private var deleteSubcategory: Subcategory? {
        didSet {
            showDeleteSubcategoryConfirmation = true
        }
    }

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
                            "Edit Serving Styles",
                            systemImage: "pencil",
                            action: { sheet = .categoryServingStyle(category: category) }
                        )
                        Button(
                            "Add Subcategory",
                            systemImage: "plus",
                            action: { sheet = .addSubcategory(category: category, onSubmit: { newSubcategoryName in
                                await appEnvironmentModel.addSubcategory(
                                    category: category,
                                    name: newSubcategoryName
                                )
                            }) }
                        )
                    } label: {
                        Label("Options menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    }
                    .sheets(item: $sheet)
                }
            }
            .headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Categories")
        .toolbar {
            toolbarContent
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await appEnvironmentModel.initialize(reset: true)
        }
        #endif
        .confirmationDialog("Are you sure you want to delete subcategory?",
                            isPresented: $showDeleteSubcategoryConfirmation,
                            titleVisibility: .visible,
                            presenting: deleteSubcategory)
        { presenting in
            ProgressButton(
                "Delete \(presenting.name)",
                role: .destructive,
                action: { await appEnvironmentModel.deleteSubcategory(presenting) }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(
                "Add Category",
                systemImage: "plus",
                action: { sheet = .addCategory(onSubmit: { _ in
                    feedbackEnvironmentModel.toggle(.success("Category created!"))
                }) }
            )
            .labelStyle(.iconOnly)
            .bold()
        }
    }
}
