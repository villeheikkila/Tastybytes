import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

private let logger = Logger(category: "CategoryPickerSheet")

struct CategoryPickerSheet: View {
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var category: Int?

    @State private var searchTerm = ""

    var shownCategories: [Models.Category.JoinedSubcategoriesServingStyles] {
        appDataEnvironmentModel.categories.filter { category in
            searchTerm.isEmpty ||
                category.name.contains(searchTerm) ||
                category.subcategories.contains(where: { subcategory in
                    subcategory.name.contains(searchTerm)
                })
        }
    }

    private var sortedCategories: [Models.Category.JoinedSubcategoriesServingStyles] {
        shownCategories.sorted { category == $0.id && category != $1.id }
    }

    var body: some View {
        List(sortedCategories, selection: $category) { category in
            CategoryNameView(category: category, withBorder: false)
        }
        .onChange(of: category) {
            dismiss()
        }
        .searchable(text: $searchTerm)
        .navigationTitle("Categories")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }
}
