import AlertToast
import SwiftUI

struct SubcategoryPicker: View {
    let availableSubcategories: [Subcategory]
    @Binding var subcategories: [Subcategory]
    @State var showToast = false
    @Environment(\.dismiss) var dismiss
    let maxSubcategories = 4
    
    func toggleSubcategory(subcategory: Subcategory) {
        if subcategories.contains(where: { $0.id == subcategory.id }) {
            subcategories.removeAll(where: { $0.id == subcategory.id })
        } else if subcategories.count < maxSubcategories {
            subcategories.append(subcategory)
        } else {
            showToast = true
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
                        if subcategories.contains(where: { $0.id == subcategory.id }) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Subcategories")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
            .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
                AlertToast(type: .error(.red), title: "You can only add \(maxSubcategories) subcategories")
            }
        }
    }
}
