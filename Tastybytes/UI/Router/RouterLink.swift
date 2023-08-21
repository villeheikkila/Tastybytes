import SFSafeSymbols
import SwiftUI

struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(SheetEnvironmentModel.self) private var sheetEnvironmentModel

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
    init(_ titleKey: String, systemSymbol: SFSymbol, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture, label: {
            Label(titleKey, systemSymbol: systemSymbol)
        })
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    init(_ titleKey: String, systemSymbol: SFSymbol, sheet: Sheet, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, label: {
            Label(titleKey, systemSymbol: systemSymbol)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: String, systemSymbol: SFSymbol, color: Color, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemSymbol: systemSymbol, color: color)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: String, systemSymbol: SFSymbol, color: Color, sheet: Sheet, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemSymbol: systemSymbol, color: color)
        })
    }
}

struct LinkIconLabel: View {
    let titleKey: String
    let systemSymbol: SFSymbol
    let color: Color

    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color.gradient)
                    .clipShape(.circle)
                Image(systemSymbol: systemSymbol)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.trailing, 8)
            .accessibilityHidden(true)
            Text(titleKey)
        }
    }
}
