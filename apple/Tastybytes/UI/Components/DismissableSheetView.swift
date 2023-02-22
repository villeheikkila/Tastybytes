import SwiftUI

struct DismissableSheet<RootView: View>: View {
  @Environment(\.dismiss) private var dismiss
  let view: () -> RootView
  let title: String

  init(
    title: String,
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
    self.title = title
  }

  var body: some View {
    view()
      .navigationTitle(title)
      .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
        Text("Cancel").bold()
      }))
  }
}
