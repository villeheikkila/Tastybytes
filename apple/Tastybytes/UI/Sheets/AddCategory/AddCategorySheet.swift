import SwiftUI

struct AddCategorySheet: View {
  @State private var newCategoryName = ""

  let onSubmit: (_ newCategoryName: String) async -> Void

  var body: some View {
    DismissableSheet(title: "Add Category") { dismiss in
      Form {
        TextField("Name", text: $newCategoryName)
        ProgressButton("Add", action: {
          await onSubmit(newCategoryName)
          dismiss()
        }).disabled(newCategoryName.isEmpty)
      }
    }
  }
}
