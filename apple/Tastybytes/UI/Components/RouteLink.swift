import SwiftUI

struct RouteLink<Label: View>: View {
  let screen: Screen
  let label: Label

  init(screen: Screen, @ViewBuilder label: () -> Label) {
    self.screen = screen
    self.label = label()
  }

  var body: some View {
    NavigationLink(value: screen) {
      label
    }
  }
}
