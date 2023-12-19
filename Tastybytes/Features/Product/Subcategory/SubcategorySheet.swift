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
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
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
            TextField("TextField", text: $newSubcategoryName)
            Button("Cancel", role: .cancel, action: {})
            ProgressButton("Create", action: {
                await appDataEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
            })
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .confirmationAction) {
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
}
