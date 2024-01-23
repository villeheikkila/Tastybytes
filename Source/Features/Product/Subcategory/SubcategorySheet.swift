import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct SubcategorySheet: View {
    private let logger = Logger(category: "SubcategorySheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var subcategories: Set<Int>
    @State private var showAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var searchTerm = ""
    let category: Models.Category.JoinedSubcategoriesServingStyles

    var shownSubcategories: [Subcategory] {
        category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
    }

    private var sortedSubcategories: [Subcategory] {
        shownSubcategories.sorted { subcategories.contains($0.id) && !subcategories.contains($1.id) }
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && shownSubcategories.isEmpty
    }

    var body: some View {
        List(sortedSubcategories, selection: $subcategories) { subcategory in
            Text(subcategory.name)
        }
        .environment(\.defaultMinListRowHeight, 50)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("Subcategories")
        .toolbar {
            toolbarContent
        }
        .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
            TextField("Name of subcategory", text: $newSubcategoryName)
            Button("actions.cancel", role: .cancel, action: {})
            ProgressButton("Create", action: {
                await appEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
            })
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneAction()
        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Add subcategory", systemImage: "plus", action: { showAddSubcategory.toggle() })
                    .labelStyle(.iconOnly)
                    .bold()
            }
        }
    }
}
