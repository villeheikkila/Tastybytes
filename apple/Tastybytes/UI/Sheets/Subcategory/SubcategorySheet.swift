import AlertToast
import SwiftUI

struct SubcategorySheet: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @Binding var subcategories: [Subcategory]
  @State private var showToast = false
  @State private var showAddSubcategory = false
  @State private var newSubcategoryName = ""
  @State private var searchTerm = ""
  let category: Category.JoinedSubcategories

  private let maxSubcategories = 4
  let onCreate: (_ newSubcategoryName: String) async -> Void

  var shownSubcategories: [Subcategory] {
    category.subcategories.sorted().filter { searchTerm.isEmpty || $0.name.contains(searchTerm) }
  }

  var body: some View {
    List {
      Section {
        ForEach(shownSubcategories) { subcategory in
          Button(action: { toggleSubcategory(subcategory: subcategory) }, label: {
            HStack {
              Text(subcategory.name)
              Spacer()
              Label("Selected subcategory", systemImage: "checkmark")
                .labelStyle(.iconOnly)
                .opacity(subcategories.contains(subcategory) ? 1 : 0)
            }
          })
        }
      } header: {
        Text("Subcategories of \(category.name)")
      }
    }
    .searchable(text: $searchTerm)
    .navigationTitle("Subcategories")
    .navigationBarItems(leading: addSubcategoryView,
                        trailing: Button("Done", action: { dismiss() }).bold())
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .error(.red), title: "You can only add \(maxSubcategories) subcategories")
    }
    .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
      TextField("TextField", text: $newSubcategoryName)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Create", action: {
        await onCreate(newSubcategoryName)
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
      showToast = true
    }
  }

  @ViewBuilder private var addSubcategoryView: some View {
    if profileManager.hasPermission(.canDeleteBrands) {
      Button("Add subcategory", systemImage: "plus", action: { showAddSubcategory.toggle() })
        .labelStyle(.iconOnly)
        .bold()
    }
  }
}
