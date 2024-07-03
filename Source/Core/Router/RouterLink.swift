import Components
import SwiftUI

struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router

    let open: Router.Open
    let asTapGesture: Bool
    let label: LabelView

    init(open: Router.Open, asTapGesture: Bool = false, @ViewBuilder label: () -> LabelView) {
        self.open = open
        self.asTapGesture = asTapGesture
        self.label = label()
    }

    var body: some View {
        if asTapGesture {
            label
                .accessibilityAddTraits(.isLink)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentShape(.rect)
                .onTapGesture {
                    router.open(open)
                }
        } else if case let .screen(screen, resetStack, removeLast) = open {
            if UIDevice.isMac || resetStack || removeLast {
                Button(action: { router.open(open) }, label: {
                    HStack {
                        label
                        Spacer()
                    }
                    .contentShape(.rect)
                })
                .buttonStyle(.plain)
                .accessibilityAddTraits(.isLink)
            } else {
                NavigationLink(value: screen, label: {
                    label
                    Spacer()
                })
                .contentShape(.rect)
            }
        } else {
            Button(action: {
                router.open(open)
            }, label: { label })
                .accessibilityAddTraits(.isLink)
        }
    }
}

extension RouterLink where LabelView == Text {
    init(_ label: LocalizedStringKey, open: Router.Open, asTapGesture: Bool = false) {
        self.init(open: open, asTapGesture: asTapGesture) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Text {
    @_disfavoredOverload
    init(_ label: String, open: Router.Open, asTapGesture: Bool = false) {
        self.init(open: open, asTapGesture: asTapGesture) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    @_disfavoredOverload
    init(_ titleKey: String, systemImage: String, open: Router.Open, asTapGesture: Bool = false) {
        self.init(open: open, asTapGesture: asTapGesture, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemImage: String, open: Router.Open, asTapGesture: Bool = false) {
        self.init(open: open, asTapGesture: asTapGesture, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: LocalizedStringKey, systemName: String, color: Color, open: Router.Open, asTapGesture: Bool = false) {
        self.init(open: open, asTapGesture: asTapGesture, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}
