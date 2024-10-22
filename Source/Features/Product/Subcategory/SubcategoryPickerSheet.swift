import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct SubcategoryPickerSheet: View {
    private let logger = Logger(label: "SubcategoryPickerSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @Binding var subcategories: [Subcategory.Saved]
    @State private var newSubcategoryName = ""
    @State private var searchTerm = ""

    let category: Models.Category.JoinedSubcategoriesServingStyles

    private var availableSubcategories: [Subcategory.Saved] {
        appModel.categories
            .first(where: { $0.id == category.id })?
            .subcategories
            .sorted() ?? []
    }

    private var filteredSubcategories: [Subcategory.Saved] {
        availableSubcategories.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    private var sortedSubcategories: [Subcategory.Saved] {
        filteredSubcategories.sorted { subcategories.contains($0) && !subcategories.contains($1) }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredSubcategories.isEmpty
    }

    var body: some View {
        List(sortedSubcategories, selection: $subcategories.map(getter: { subcategories in
            Set(subcategories.map(\.id))
        }, setter: { ids in
            ids.compactMap { id in availableSubcategories.first(where: { $0.id == id }) }
        })) { subcategory in
            SubcategoryView(subcategory: subcategory)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 50)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .safeAreaInset(edge: .bottom) {
            if profileModel.hasPermission(.canAddSubcategories) {
                Form {
                    Section("subcategory.add.name") {
                        TextField("subcategory.name.placeholder", text: $newSubcategoryName)
                        AsyncButton("labels.create") {
                            await appModel.addSubcategory(category: category, name: newSubcategoryName) { subcategory in
                                newSubcategoryName = ""
                                subcategories.append(subcategory)
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 8))
                .padding()
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
