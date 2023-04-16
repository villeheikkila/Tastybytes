import SwiftUI

struct DismissableSheet<RootView: View>: View {
  @Environment(\.dismiss) private var dismiss

  let title: String
  let view: (_ dismiss: DismissAction) -> RootView

  var body: some View {
    view(dismiss)
      .navigationTitle(title)
      .navigationBarItems(leading: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }
}
