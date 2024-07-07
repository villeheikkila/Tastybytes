import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import SwiftUI

struct CategoryPickerSheet: View {
    private let logger = Logger(category: "CategoryPickerSheet")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var category: Models.Category.JoinedSubcategoriesServingStyles?

    @State private var searchTerm = ""

    private var shownCategories: [Models.Category.JoinedSubcategoriesServingStyles] {
        appEnvironmentModel.categories.filter { category in
            searchTerm.isEmpty ||
                category.name.contains(searchTerm) ||
                category.subcategories.contains(where: { subcategory in
                    subcategory.name.contains(searchTerm)
                })
        }
    }

    private var sortedCategories: [Models.Category.JoinedSubcategoriesServingStyles] {
        shownCategories.sorted { category?.id == $0.id && category?.id != $1.id }
    }

    var body: some View {
        List(sortedCategories, selection: $category.map(getter: { _ in category?.id }, setter: { id in
            appEnvironmentModel.categories.first(where: { c in c.id == id })
        })) { category in
            HStack {
                if let icon = category.icon {
                    Text(icon)
                        .grayscale(1)
                }
                Text(category.name)
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
        .onChange(of: category) {
            dismiss()
        }
        .searchable(text: $searchTerm)
        .navigationTitle("category.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneActionView()
    }
}
