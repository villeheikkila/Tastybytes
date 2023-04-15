import SwiftUI

struct AddCategorySheet: View {
  @EnvironmentObject private var appDataManager: AppDataManager
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
