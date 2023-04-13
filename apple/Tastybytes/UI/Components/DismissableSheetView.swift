import SwiftUI

struct DismissableSheet<RootView: View>: View {
  @Environment(\.dismiss) private var dismiss
  let view: (_ dismiss: DismissAction) -> RootView
  let title: String

  init(
    title: String,
    @ViewBuilder view: @escaping (_ dismiss: DismissAction) -> RootView
  ) {
    self.view = view
    self.title = title
  }

  var body: some View {
    view(dismiss)
      .navigationTitle(title)
      .navigationBarItems(leading: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }
}
