import SwiftUI

struct SubcategorySheet: View {
  private let logger = getLogger(category: "SubcategorySheet")
  @Environment(Repository.self) private var repository
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @Environment(AppDataManager.self) private var appDataManager
  @Environment(\.dismiss) private var dismiss
  @Binding var subcategories: [Subcategory]
  @State private var showAddSubcategory = false
  @State private var newSubcategoryName = ""
  @State private var searchTerm = ""
  let category: Category.JoinedSubcategoriesServingStyles

  private let maxSubcategories = 4

  var shownSubcategories: [Subcategory] {
    category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
  }

  var body: some View {
    List {
      Section("Subcategories of \(category.name)") {
        ForEach(shownSubcategories) { subcategory in
          Button(action: { toggleSubcategory(subcategory: subcategory) }, label: {
            HStack {
              Text(subcategory.name)
              Spacer()
              Label("Selected subcategory", systemSymbol: .checkmark)
                .labelStyle(.iconOnly)
                .opacity(subcategories.contains(subcategory) ? 1 : 0)
            }
          })
        }
      }
    }
    .searchable(text: $searchTerm)
    .navigationTitle("Subcategories")
    .navigationBarItems(leading: addSubcategoryView,
                        trailing: Button("Done", action: { dismiss() }).bold())
    .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
      TextField("TextField", text: $newSubcategoryName)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Create", action: {
        await appDataManager.addSubcategory(category: category, name: newSubcategoryName)
      })
    })
  }

  private func toggleSubcategory(subcategory: Subcategory) {
    if subcategories.contains(subcategory) {
      withAnimation {
        subcategories.remove(object: subcategory)
      }
    } else if subcategories.count < maxSubcategories {
      withAnimation {
        subcategories.append(subcategory)
      }
    } else {
      feedbackManager.toggle(.warning("You can only add \(maxSubcategories) subcategories"))
    }
  }

  @ViewBuilder private var addSubcategoryView: some View {
    if profileManager.hasPermission(.canDeleteBrands) {
      Button("Add subcategory", systemSymbol: .plus, action: { showAddSubcategory.toggle() })
        .labelStyle(.iconOnly)
        .bold()
    }
  }
}
