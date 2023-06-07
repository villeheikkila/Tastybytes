import SwiftUI

struct AddCategorySheet: View {
  @Environment(AppDataManager.self) private var appDataManager
  @State private var newCategoryName = ""

  let onSubmit: (_ newCategoryName: String) async -> Void

  var body: some View {
    DismissableSheet(title: "Add Category") { dismiss in
      Form {
        TextField("Name", text: $newCategoryName)
        ProgressButton("Add", action: {
          await appDataManager.addCategory(name: newCategoryName)
          dismiss()
        }).disabled(newCategoryName.isEmpty)
      }
    }
  }
}
