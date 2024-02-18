import OSLog
import SwiftUI

@MainActor
public struct ProgressButton<LabelView: View>: View {
    private let logger = Logger(category: "ProgressButton")
    public enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }

    let role: ButtonRole?
    var action: () async -> Void
    var actionOptions: Set<ActionOption> = Set([.disableButton, .showProgressView])
    @ViewBuilder var label: () -> LabelView
    @State private var task: Task<Void, Never>?

    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        actionOptions: Set<ActionOption> = Set([.disableButton, .showProgressView]),
        @ViewBuilder label: @escaping () -> LabelView
    ) {
        self.role = role
        self.action = action
        self.actionOptions = actionOptions
        self.label = label
    }

    @State private var isDisabled = false
    @State private var isLoading = false

    let cancelTaskOnDisappear = false

    public var body: some View {
        Button(role: role, action: { buttonAction() }, label: { buttonLabel })
            .disabled(isDisabled)
            .onDisappear {
                if cancelTaskOnDisappear {
                    task?.cancel()
                }
            }
    }

    private func buttonAction() {
        if actionOptions.contains(.disableButton) {
            isDisabled = true
        }

        task = Task(priority: .userInitiated) {
            defer { task = nil }
            var progressViewTask: Task<Void, Error>?
            if actionOptions.contains(.showProgressView) {
                progressViewTask = Task {
                    do {
                        try await Task.sleep(for: .seconds(1))
                        isLoading = true
                    } catch {}
                }
            }
            await action()
            progressViewTask?.cancel()
            isDisabled = false
            isLoading = false
        }
    }

    private var buttonLabel: some View {
        HStack {
            label()
            if isLoading {
                ProgressView()
                    .padding(.leading, 10)
            }
        }
    }
}

public extension ProgressButton where LabelView == Text {
    @_disfavoredOverload
    init(_ label: String,
         role: ButtonRole? = nil,
         actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action, actionOptions: actionOptions) {
            Text(label)
        }
    }
}

public extension ProgressButton where LabelView == Text {
    init(_ label: LocalizedStringKey,
         role: ButtonRole? = nil,
         actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action, actionOptions: actionOptions) {
            Text(label)
        }
    }
}

public extension ProgressButton where LabelView == Label<Text, Image> {
    @_disfavoredOverload
    init(_ title: String, systemImage: String,
         role: ButtonRole? = nil,
         actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action, actionOptions: actionOptions) {
            Label(title, systemImage: systemImage)
        }
    }
}

public extension ProgressButton where LabelView == Label<Text, Image> {
    init(_ title: LocalizedStringKey, systemImage: String,
         role: ButtonRole? = nil,
         actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action, actionOptions: actionOptions) {
            Label(title, systemImage: systemImage)
        }
    }
}

public extension ProgressButton where LabelView == LinkIconLabel {
    init(
        _ titleKey: LocalizedStringKey,
        systemName: String,
        color: Color,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping () async -> Void
    ) {
        self.init(action: action, actionOptions: actionOptions) {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        }
    }
}

public struct LinkIconLabel: View {
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
        }
    }
}
