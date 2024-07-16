import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct SubcategoryPickerSheet: View {
    private let logger = Logger(category: "SubcategoryPickerSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Binding var subcategories: [Subcategory]
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
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 50)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .safeAreaInset(edge: .bottom) {
            if profileEnvironmentModel.hasPermission(.canDeleteBrands) {
                Form {
                    Section("subcategory.add.name") {
                        TextField("subcategory.name.placeholder", text: $newSubcategoryName)
                        AsyncButton("labels.create") {
                            await appEnvironmentModel.addSubcategory(category: category, name: newSubcategoryName)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
                .frame(height: 150)
            }
        }
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("subcategory.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
