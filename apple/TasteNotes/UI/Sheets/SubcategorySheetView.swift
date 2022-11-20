import AlertToast
import SwiftUI

struct SubcategorySheetView: View {
    let availableSubcategories: [Subcategory]
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var subcategories: [Subcategory]
    @State var showToast = false
    @State var showAddSubcategory = false
    @State var newSubcategoryName = ""
    @Environment(\.dismiss) var dismiss
    let maxSubcategories = 4

    let onCreate: (_ newSubcategoryName: String) -> Void

    func toggleSubcategory(subcategory: Subcategory) {
        if subcategories.contains(subcategory) {
            subcategories.remove(object: subcategory)
        } else if subcategories.count < maxSubcategories {
            subcategories.append(subcategory)
        } else {
            showToast = true
        }
    }

    @ViewBuilder
    var addSubcategoryView: some View {
        if profileManager.hasPermission(.canDeleteBrands) {
            Button(action: {
                showAddSubcategory.toggle()
            }) {
                Image(systemName: "plus").bold()
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(availableSubcategories, id: \.self) { subcategory in
                Button(action: {
                    toggleSubcategory(subcategory: subcategory)
                }) {
                    HStack {
                        Text(subcategory.name)
                        Spacer()
                        if subcategories.contains(subcategory) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Subcategories")
            .navigationBarItems(leading: addSubcategoryView,
                                trailing: Button(action: {
                                    dismiss()
                                }) {
                                    Text("Done").bold()
                                })
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
    }
}
