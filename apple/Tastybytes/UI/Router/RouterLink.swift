import SwiftUI

struct RouteLink<Label: View>: View {
  @EnvironmentObject private var router: Router
  let screen: Screen?
  let sheet: Sheet?
  let asTapGesture: Bool
  let label: Label

  init(screen: Screen, asTapGesture: Bool = false, @ViewBuilder label: () -> Label) {
    self.screen = screen
    sheet = nil
    self.asTapGesture = asTapGesture
    self.label = label()
  }

  init(sheet: Sheet, asTapGesture: Bool = false, @ViewBuilder label: () -> Label) {
    self.sheet = sheet
    screen = nil
    self.asTapGesture = asTapGesture
    self.label = label()
  }

  var body: some View {
    if asTapGesture {
      label
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isLink)
        .onTapGesture {
          if let screen {
            router.navigate(screen: screen)
          } else if let sheet {
            router.navigate(sheet: sheet)
          }
        }
    } else if let screen {
      NavigationLink(value: screen, label: { label })
    } else if let sheet {
      Button(action: { router.navigate(sheet: sheet) }, label: { label })
    }
  }
}

extension RouteLink where Label == Text {
  init(_ label: String, screen: Screen, asTapGesture: Bool = false) {
    self.init(screen: screen, asTapGesture: asTapGesture) {
      Text(label)
    }
  }
}

extension RouteLink where Label == Image {
  init(systemImageName: String, screen: Screen, asTapGesture: Bool = false) {
    self.init(screen: screen, asTapGesture: asTapGesture) {
      Image(systemName: systemImageName)
    }
  }
}

extension RouteLink where Label == Text {
  init(_ label: String, sheet: Sheet, asTapGesture: Bool = false) {
    self.init(sheet: sheet, asTapGesture: asTapGesture) {
      Text(label)
    }
  }
}

extension RouteLink where Label == Image {
  init(systemImageName: String, sheet: Sheet, asTapGesture: Bool = false) {
    self.init(sheet: sheet, asTapGesture: asTapGesture) {
      Image(systemName: systemImageName)
    }
  }
}
