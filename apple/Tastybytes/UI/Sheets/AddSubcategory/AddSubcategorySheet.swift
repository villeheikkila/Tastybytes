import SwiftUI

struct AddSubcategorySheet: View {
  @State private var newSubcategoryName = ""
  let category: CategoryProtocol
  let onSubmit: (_ newSubcategoryName: String) -> Void

  var body: some View {
    DismissableSheet(title: "Add subcategory to \(category.name)") {
      Form {
        Section {
          TextField("Name", text: $newSubcategoryName)
          Button(action: { onSubmit(newSubcategoryName) }, label: {
            Text("Add")
          }).disabled(newSubcategoryName.isEmpty)
        } header: {
          Text("Add Subcategory")
        }
      }
    }.navigationBarTitleDisplayMode(.inline)
  }
}
