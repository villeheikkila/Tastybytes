import SwiftUI

struct EditSubcategorySheet: View {
  @State private var subcategoryName = ""
  let subcategory: Subcategory
  let onSubmit: (_ subcategoryName: String) -> Void

  init(subcategory: Subcategory, onSubmit: @escaping (_ subcategoryName: String) -> Void) {
    _subcategoryName = State(wrappedValue: subcategory.name)
    self.subcategory = subcategory
    self.onSubmit = onSubmit
  }

  var body: some View {
    DismissableSheet(title: "Edit \(subcategory.name)") {
      Form {
        TextField("Name", text: $subcategoryName)
        Button(
          action: { onSubmit(subcategoryName) },
          label: { Text("Save changes") }
        ).disabled(subcategoryName.isEmpty || subcategory.name == subcategoryName)
      }
    }
  }
}
