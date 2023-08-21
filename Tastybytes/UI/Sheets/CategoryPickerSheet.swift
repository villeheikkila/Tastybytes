import Models
import OSLog
import SwiftUI

private let logger = Logger(category: "CategoryPickerSheet")

struct CategoryPickerSheet: View {
    @Environment(AppDataManager.self) private var appDataManager
    @Environment(\.dismiss) private var dismiss
    @Binding var category: Models.Category.JoinedSubcategoriesServingStyles?
    @State private var searchTerm = ""

    var shownCategories: [Models.Category.JoinedSubcategoriesServingStyles] {
        appDataManager.categories
            .filter { category in
                searchTerm.isEmpty || category.name.contains(searchTerm) || category.subcategories
                    .contains(where: { subcategory in
                        subcategory.name.contains(searchTerm)
                    })
            }
    }

    var body: some View {
        List {
            ForEach(shownCategories) { category in
                Button(action: {
                    self.category = category
                    dismiss()
                }, label: {
                    HStack(spacing: 12) {
                        Group {
                            Text(category.icon)
                                .grayscale(1)
                            Text(category.name)
                        }
                    }
                })
            }
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
