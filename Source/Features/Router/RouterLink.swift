import Components
import SwiftUI

@MainActor
struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(SheetManager.self) private var sheetManager
    @State private var activeSheet: Sheet?

    let screen: Screen?
    let sheet: Sheet?
    let asTapGesture: Bool
    let label: LabelView
    let useRootSheetManager: Bool

    init(screen: Screen, asTapGesture: Bool = false, @ViewBuilder label: () -> LabelView) {
        self.screen = screen
        sheet = nil
        self.asTapGesture = asTapGesture
        self.label = label()
        useRootSheetManager = false
    }

    init(sheet: Sheet, asTapGesture: Bool = false, useRootSheetManager: Bool = false, @ViewBuilder label: () -> LabelView) {
        self.sheet = sheet
        screen = nil
        self.asTapGesture = asTapGesture
        self.label = label()
        self.useRootSheetManager = useRootSheetManager
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
                        openSheet(sheet: sheet)
                    }
                }
                .sheets(item: $activeSheet)
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
            Button(action: { openSheet(sheet: sheet)
            }, label: { label })
                .sheets(item: $activeSheet)
        }
    }

    func openSheet(sheet: Sheet) {
        if useRootSheetManager {
            sheetManager.navigate(sheet: sheet)
        } else {
            activeSheet = sheet
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
    init(_ label: String, sheet: Sheet, useRootSheetManager: Bool = false, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, useRootSheetManager: useRootSheetManager) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Text {
    init(_ label: LocalizedStringKey, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Text {
    init(_ label: LocalizedStringKey, sheet: Sheet, useRootSheetManager: Bool = false, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, useRootSheetManager: useRootSheetManager) {
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
    init(_ titleKey: LocalizedStringKey, systemImage: String, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemImage: String, sheet: Sheet, useRootSheetManager: Bool = false, asTapGesture: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, useRootSheetManager: useRootSheetManager, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: LocalizedStringKey, systemName: String, color: Color, screen: Screen, asTapGesture: Bool = false) {
        self.init(screen: screen, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: LocalizedStringKey, systemName: String, color: Color, sheet: Sheet, asTapGesture: Bool = false, useRootSheetManager: Bool = false) {
        self.init(sheet: sheet, asTapGesture: asTapGesture, useRootSheetManager: useRootSheetManager, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}
