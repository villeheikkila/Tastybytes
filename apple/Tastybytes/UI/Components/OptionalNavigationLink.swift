import SwiftUI

struct OptionalNavigationLink<RootView: View>: View {
  let value: Route
  let disabled: Bool
  let view: () -> RootView

  init(
    value: Route,
    disabled: Bool,
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
    self.value = value
    self.disabled = disabled
  }

  var body: some View {
    if disabled {
      view()

    } else {
      NavigationLink(value: value) {
        view()
      }
      .buttonStyle(.plain)
    }
  }
}
