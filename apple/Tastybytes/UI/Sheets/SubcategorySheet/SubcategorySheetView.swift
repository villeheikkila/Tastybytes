import AlertToast
import SwiftUI

struct SubcategorySheetView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @Binding var subcategories: [Subcategory]
  @State private var showToast = false
  @State private var showAddSubcategory = false
  @State private var newSubcategoryName = ""

  private let maxSubcategories = 4
  let availableSubcategories: [Subcategory]
  let onCreate: (_ newSubcategoryName: String) -> Void

  var body: some View {
    List(availableSubcategories, id: \.self) { subcategory in
      Button(action: { toggleSubcategory(subcategory: subcategory) }, label: {
        HStack {
          Text(subcategory.name)
          Spacer()
          if subcategories.contains(subcategory) {
            Image(systemName: "checkmark")
          }
        }
      })
    }
    .navigationTitle("Subcategories")
    .navigationBarItems(leading: addSubcategoryView,
                        trailing: Button(action: { dismiss() }, label: {
                          Text("Done").bold()
                        }))
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .error(.red), title: "You can only add \(maxSubcategories) subcategories")
    }
    .alert("Add new subcategory", isPresented: $showAddSubcategory, actions: {
      TextField("TextField", text: $newSubcategoryName)
      Button("Cancel", role: .cancel, action: {})
      Button("Create", action: {
        onCreate(newSubcategoryName)
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

  @ViewBuilder
  private var addSubcategoryView: some View {
    if profileManager.hasPermission(.canDeleteBrands) {
      Button(action: { showAddSubcategory.toggle() }, label: {
        Image(systemName: "plus").bold()
      })
    }
  }
}
