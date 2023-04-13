import SwiftUI

struct NewFlavorSheet: View {
  @State private var name = ""

  let onSubmit: (_ name: String) async -> Void

  var body: some View {
    DismissableSheet(title: "Add Flavor") { dismiss in
      Form {
        TextField("Name", text: $name)
        ProgressButton("Add", action: {
          await onSubmit(name)
          dismiss()
        })
      }
    }
  }
}
