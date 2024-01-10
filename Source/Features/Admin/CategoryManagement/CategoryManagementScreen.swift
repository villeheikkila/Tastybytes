import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

@MainActor
struct CategoryManagementScreen: View {
    private let logger = Logger(category: "CategoryManagementScreen")
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appDataEnvironmentModel
    @State private var showDeleteSubcategoryConfirmation = false
    @State private var verifySubcategory: Subcategory?
    @State private var deleteSubcategory: Subcategory? {
        didSet {
            showDeleteSubcategoryConfirmation = true
        }
    }

    var body: some View {
        List(appDataEnvironmentModel.categories) { category in
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
                        RouterLink(
                            "Edit Serving Styles",
                            systemImage: "pencil",
                            sheet: .categoryServingStyle(category: category)
                        )
                        RouterLink(
                            "Add Subcategory",
                            systemImage: "plus",
                            sheet: .addSubcategory(category: category, onSubmit: { newSubcategoryName in
                                await appDataEnvironmentModel.addSubcategory(
                                    category: category,
                                    name: newSubcategoryName
                                )
                            })
                        )
                    } label: {
                        Label("Options menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24)
                    }
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
            await appDataEnvironmentModel.initialize(reset: true)
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
                action: { await appDataEnvironmentModel.deleteSubcategory(presenting) }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink(
                "Add Category",
                systemImage: "plus",
                sheet: .addCategory(onSubmit: { _ in
                    feedbackEnvironmentModel.toggle(.success("Category created!"))
                })
            )
            .labelStyle(.iconOnly)
            .bold()
        }
    }
}
