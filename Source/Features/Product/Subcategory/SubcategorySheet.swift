import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategorySheet: View {
    private let logger = Logger(category: "SubcategorySheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var subcategories: [Subcategory]
    @State private var showAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var searchTerm = ""

    let category: Models.Category.JoinedSubcategoriesServingStyles

    private var shownSubcategories: [Subcategory] {
        category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
    }

    private var sortedSubcategories: [Subcategory] {
        shownSubcategories.sorted { subcategories.contains($0) && !subcategories.contains($1) }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && shownSubcategories.isEmpty
    }

    var body: some View {
        List(sortedSubcategories, selection: $subcategories.map(getter: { subcategories in
            Set(subcategories.map(\.id))
        }, setter: { ids in
            ids.compactMap { id in category.subcategories.first(where: { $0.id == id }) }
        })) { subcategory in
            Text(subcategory.name)
        }
        .environment(\.defaultMinListRowHeight, 50)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("subcategory.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .alert("subcategory.add.name", isPresented: $showAddSubcategory, actions: {
            TextField("subcategory.name.placeholder", text: $newSubcategoryName)
            Button("labels.cancel", role: .cancel, action: {})
            ProgressButton("labels.create", action: {
                await appEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
            })
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneActionView()
        if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("subcategory.add.openSheet.label", systemImage: "plus", action: { showAddSubcategory.toggle() })
                    .labelStyle(.iconOnly)
                    .bold()
            }
        }
    }
}
