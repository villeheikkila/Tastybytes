import SwiftUI

struct RouteLink<Label: View>: View {
  let route: Screen
  let label: Label

  init(to route: Screen, @ViewBuilder label: () -> Label) {
    self.route = route
    self.label = label()
  }

  var body: some View {
    NavigationLink(value: route) {
      label
    }
  }
}
