import SwiftUI

struct AddSubcategorySheet: View {
  @State private var newSubcategoryName = ""
  let category: CategoryProtocol
  let onSubmit: (_ newSubcategoryName: String) async -> Void

  var body: some View {
    DismissableSheet(title: "Add subcategory to \(category.name)") { dismiss in
      Form {
        Section {
          TextField("Name", text: $newSubcategoryName)
          ProgressButton(action: {
            await onSubmit(newSubcategoryName)
            dismiss()
          }, label: {
            Text("Add")
          }).disabled(newSubcategoryName.isEmpty)
        } header: {
          Text("Add Subcategory")
        }
      }
    }.navigationBarTitleDisplayMode(.inline)
  }
}
