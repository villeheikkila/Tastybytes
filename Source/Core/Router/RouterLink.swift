import Components
import SwiftUI

struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(\.routerLinkMode) private var routerLinkMode
    @Environment(\.routerLinkDisabled) private var routerLinkDisabled

    let open: Router.Open
    let label: LabelView

    init(open: Router.Open, @ViewBuilder label: () -> LabelView) {
        self.open = open
        self.label = label()
    }

    var body: some View {
        if routerLinkDisabled {
            label
        } else if routerLinkMode == .button {
            Button(action: { router.open(open) }, label: {
                label
            })
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isLink)
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

enum RouterLinkMode {
    case button
    case preferNavigationLink
}

extension EnvironmentValues {
    @Entry var routerLinkMode: RouterLinkMode = .preferNavigationLink
}

extension View {
    func routerLinkMode(_ mode: RouterLinkMode) -> some View {
        environment(\.routerLinkMode, mode)
    }
}

extension EnvironmentValues {
    @Entry var routerLinkDisabled: Bool = false
}

extension View {
    func routerLinkDisabled(_ enabled: Bool) -> some View {
        environment(\.routerLinkDisabled, enabled)
    }
}


extension RouterLink where LabelView == Text {
    init(_ label: LocalizedStringKey, open: Router.Open) {
        self.init(open: open) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Text {
    @_disfavoredOverload
    init(_ label: String, open: Router.Open) {
        self.init(open: open) {
            Text(label)
        }
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    @_disfavoredOverload
    init(_ titleKey: String, systemImage: String, open: Router.Open) {
        self.init(open: open, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == Label<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemImage: String, open: Router.Open) {
        self.init(open: open, label: {
            Label(titleKey, systemImage: systemImage)
        })
    }
}

extension RouterLink where LabelView == LinkIconLabel {
    init(_ titleKey: LocalizedStringKey, systemName: String, color: Color, open: Router.Open) {
        self.init(open: open, label: {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}
