import Components
import SwiftUI

struct RouterLink<LabelView: View>: View {
    @Environment(Router.self) private var router
    @Environment(\.routerLinkMode) private var routerLinkMode
    @Environment(\.routerLinkDisabled) private var routerLinkDisabled

    let open: Router.Open
    @ViewBuilder let label: () -> LabelView

    var body: some View {
        Group {
            if routerLinkDisabled {
                label()
            } else {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        // TODO: Enable after double navigation is fixed
        if false, routerLinkMode == .preferNavigationLink, case let .screen(screen, resetStack, removeLast) = open, !resetStack || !removeLast {
            NavigationLink(value: screen, label: label)
        } else {
            Button(action: { router.open(open) }, label: label)
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

extension RouterLink where LabelView == HStack<TupleView<(Text, Spacer, Text)>> {
    init(_ label: LocalizedStringKey, count: Int, open: Router.Open) {
        self.init(open: open) {
            HStack {
                Text(label)
                Spacer()
                Text(count == 0 ? "" : count.formatted())
                    .foregroundStyle(.yellow)
            }
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

extension RouterLink where LabelView == HStack<TupleView<(Label<Text, Image>, Spacer, Text)>> {
    init(_ label: LocalizedStringKey, systemImage: String, count: Int, open: Router.Open) {
        self.init(open: open) {
            HStack {
                Label(label, systemImage: systemImage)
                Spacer()
                Text(count == 0 ? "" : count.formatted())
                    .foregroundStyle(.yellow)
            }
        }
    }
}

extension RouterLink where LabelView == LinkIconLabelView {
    init(_ titleKey: LocalizedStringKey, systemName: String, color: Color, open: Router.Open) {
        self.init(open: open, label: {
            LinkIconLabelView(titleKey: titleKey, systemName: systemName, color: color)
        })
    }
}
