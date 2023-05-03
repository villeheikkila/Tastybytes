import SwiftUI

struct CategorySheet: View {
  private let logger = getLogger(category: "CategorySheet")
  @EnvironmentObject private var appDataManager: AppDataManager
  @Environment(\.dismiss) private var dismiss
  @Binding var category: Category.JoinedSubcategoriesServingStyles
  @State private var searchTerm = ""

  var shownCategories: [Category.JoinedSubcategoriesServingStyles] {
    appDataManager.categories.filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
  }

  var body: some View {
    List {
      Section("Pick a Category") {
        ForEach(shownCategories) { category in
          Button(action: {
            self.category = category
            dismiss()
          }, label: {
            HStack {
              Text(category.label)
              Spacer()
            }
          })
        }
        .searchable(text: $searchTerm)
        .navigationTitle("Categories")
        .navigationBarItems(trailing: Button("Done", action: { dismiss() }).bold())
      }
    }
  }
}
