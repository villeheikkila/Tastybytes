import SwiftUI

struct RouteLink<Label: View>: View {
  let route: Route
  let label: Label

  init(to route: Route, @ViewBuilder label: () -> Label) {
    self.route = route
    self.label = label()
  }

  var body: some View {
    NavigationLink(value: route) {
      label
    }
  }
}
