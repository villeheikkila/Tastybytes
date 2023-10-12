import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategorySheet: View {
    private let logger = Logger(category: "SubcategorySheet")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var subcategories: Set<Int>
    @State private var showAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var searchTerm = ""
    let category: Models.Category.JoinedSubcategoriesServingStyles

    private let maxSubcategories = 4

    var shownSubcategories: [Subcategory] {
        category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
    }

    var body: some View {
        List(shownSubcategories, selection: $subcategories) { subcategory in
            Text(subcategory.name)
        }
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .navigationTitle("Subcategories")
        .toolbar {
            toolbarContent
        }
        .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
            TextField("TextField", text: $newSubcategoryName)
            Button("Cancel", role: .cancel, action: {})
            ProgressButton("Create", action: {
                await appDataEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
            })
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Done", role: .cancel, action: { dismiss() }).bold()
        }
        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Add subcategory", systemImage: "plus", action: { showAddSubcategory.toggle() })
                    .labelStyle(.iconOnly)
                    .bold()
            }
        }
    }

    private func onLimitReached() {
        feedbackEnvironmentModel.toggle(.warning("You can only add \(maxSubcategories) subcategories"))
    }
}
