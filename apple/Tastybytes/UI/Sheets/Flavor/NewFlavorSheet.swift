import SwiftUI

struct NewFlavorSheet: View {
  @State private var name = ""

  let onSubmit: (_ name: String) -> Void

  var body: some View {
    DismissableSheet(title: "Add Flavor") {
      Form {
        TextField("Name", text: $name)
        Button(action: { onSubmit(name) }, label: {
          Text("Add")
        })
      }
    }
  }
}
