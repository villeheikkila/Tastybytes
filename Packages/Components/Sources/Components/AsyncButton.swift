import Logging
import SwiftUI

public struct AsyncButton<LabelView: View>: View {
    @Environment(\.asyncButtonLoadingStyle) private var asyncButtonLoadingStyle
    @State private var task: Task<Void, Never>?
    @State private var isDisabled = false

    let role: ButtonRole?
    let action: () async -> Void
    @ViewBuilder var label: () -> LabelView

    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> LabelView
    ) {
        self.role = role
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(role: role, action: {
            task = Task(priority: .userInitiated) {
                defer { task = nil }
                await action()
            }
        }, label: {
            label()
            if task != nil, asyncButtonLoadingStyle == .spinner {
                ProgressView()
                    .padding(.leading, 10)
            }
        })
        .disabled(task != nil)
    }
}

public enum AsyncButtonLoadingStyle: Sendable {
    case plain
    case spinner
}

extension EnvironmentValues {
    @Entry var asyncButtonLoadingStyle: AsyncButtonLoadingStyle = .plain
}

public extension View {
    func asyncButtonLoadingStyle(_ mode: AsyncButtonLoadingStyle) -> some View {
        environment(\.asyncButtonLoadingStyle, mode)
    }
}

public extension AsyncButton where LabelView == Text {
    @_disfavoredOverload
    init(_ label: String,
         role: ButtonRole? = nil,
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

public extension AsyncButton where LabelView == Text {
    init(_ label: LocalizedStringKey,
         role: ButtonRole? = nil,
         action: @MainActor @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

public extension AsyncButton where LabelView == Label<Text, Image> {
    @_disfavoredOverload
    init(_ title: String, systemImage: String,
         role: ButtonRole? = nil,
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Label {
                Text(title)
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}

public extension AsyncButton where LabelView == Label<Text, Image> {
    init(_ title: LocalizedStringKey, systemImage: String,
         role: ButtonRole? = nil,
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

public extension AsyncButton where LabelView == LinkIconLabelView {
    init(
        _ titleKey: LocalizedStringKey,
        systemName: String,
        color: Color,
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            LinkIconLabelView(titleKey: titleKey, systemName: systemName, color: color)
        }
    }
}

public struct LinkIconLabelView: View {
    let titleKey: LocalizedStringKey
    let systemName: String
    let color: Color

    public init(titleKey: LocalizedStringKey, systemName: String, color: Color) {
        self.titleKey = titleKey
        self.systemName = systemName
        self.color = color
    }

    public var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color.gradient)
                    .clipShape(.circle)
                Image(systemName: systemName)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.trailing, 8)
            .accessibilityHidden(true)
            Text(titleKey)
                .foregroundColor(.primary)
        }
    }
}
