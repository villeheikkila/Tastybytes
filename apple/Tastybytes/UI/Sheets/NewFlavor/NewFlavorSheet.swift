import SwiftUI

struct NewFlavorSheet: View {
  @State private var name = ""

  let onSubmit: (_ name: String) -> Void

  var body: some View {
    DismissableSheet(title: "Add Flavor") { dismiss in
      Form {
        TextField("Name", text: $name)
        Button(action: {
          onSubmit(name)
          dismiss()
        }, label: {
          Text("Add")
        })
      }
    }
  }
}
