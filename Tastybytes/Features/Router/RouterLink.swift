import Components
import SwiftUI

struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(SheetManager.self) private var sheetEnvironmentModel

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
                .accessibilityAddTraits(.isLink)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let screen {
                        router.navigate(screen: screen)
                    } else if let sheet {
                        sheetEnvironmentModel.navigate(sheet: sheet)
                    }
                }
        } else if let screen {
            if isPadOrMac() {
                Button(action: { router.navigate(screen: screen) }, label: {
                    HStack {
                        label
                        Spacer()
                    }
                    .contentShape(Rectangle())
                })
                .buttonStyle(.plain)
            } else {
                NavigationLink(value: screen, label: {
                    label
                    Spacer()
                })
                .contentShape(Rectangle())
            }
        } else if let sheet {
            Button(action: { sheetEnvironmentModel.navigate(sheet: sheet) }, label: { label })
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

extension RouterLink where LabelView == Text {
    init(_ label: String, sheet: Sheet, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture) {
            Text(label)
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

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: String, systemName: String, color: Color, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: String, systemName: String, color: Color, sheet: Sheet, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}