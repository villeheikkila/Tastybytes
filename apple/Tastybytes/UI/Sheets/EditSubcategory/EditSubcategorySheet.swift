import SwiftUI

struct EditSubcategorySheet: View {
  @State private var subcategoryName = ""
  let subcategory: Subcategory
  let onSubmit: (_ subcategoryName: String) async -> Void

  init(subcategory: Subcategory, onSubmit: @escaping (_ subcategoryName: String) async -> Void) {
    _subcategoryName = State(wrappedValue: subcategory.name)
    self.subcategory = subcategory
    self.onSubmit = onSubmit
  }

  var body: some View {
    DismissableSheet(title: "Edit \(subcategory.name)") { dismiss in
      Form {
        TextField("Name", text: $subcategoryName)
        ProgressButton("Save changes", action: {
          await onSubmit(subcategoryName)
          dismiss()
        }).disabled(subcategoryName.isEmpty || subcategory.name == subcategoryName)
      }
    }
  }
}
