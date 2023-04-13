import SwiftUI

struct RouterLink<LabelView: View>: View {
  @EnvironmentObject private var router: Router

  let screen: Screen?
  let sheet: Sheet?
  let asTapGesture: Bool
  let label: LabelView

  init(screen: Screen, asTapGesture: Bool = false, @ViewBuilder label: () -> LabelView) {
    self.screen = screen
    sheet = nil
    self.asTapGesture = asTapGesture
    self.label = label()
  }

  init(sheet: Sheet, asTapGesture: Bool = false, @ViewBuilder label: () -> LabelView) {
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

extension RouterLink where LabelView == Text {
  init(_ label: String, screen: Screen, asTapGesture: Bool = false) {
    self.init(screen: screen, asTapGesture: asTapGesture) {
      Text(label)
    }
  }
}

extension RouterLink where LabelView == Image {
  init(systemImageName: String, screen: Screen, asTapGesture: Bool = false) {
    self.init(screen: screen, asTapGesture: asTapGesture) {
      Image(systemName: systemImageName)
    }
  }
}

extension RouterLink where LabelView == Text {
  init(_ label: String, sheet: Sheet, asTapGesture: Bool = false) {
    self.init(sheet: sheet, asTapGesture: asTapGesture) {
      Text(label)
    }
  }
}

extension RouterLink where LabelView == Image {
  init(systemImageName: String, sheet: Sheet, asTapGesture: Bool = false) {
    self.init(sheet: sheet, asTapGesture: asTapGesture) {
      Image(systemName: systemImageName)
    }
  }
}

extension RouterLink where LabelView == Label<Text, Image> {
  init(_ titleKey: String, systemImage: String, screen: Screen, asTapGesture: Bool = false) {
    self.init(screen: screen, asTapGesture: asTapGesture, label: {
      Label(titleKey, systemImage: systemImage)
    })
  }
}

extension RouterLink where LabelView == Label<Text, Image> {
  init(_ titleKey: String, systemImage: String, sheet: Sheet, asTapGesture: Bool = false) {
    self.init(sheet: sheet, asTapGesture: asTapGesture, label: {
      Label(titleKey, systemImage: systemImage)
    })
  }
}