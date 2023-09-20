import OSLog
import SwiftUI

public struct ProgressButton<LabelView: View>: View {
    private let logger = Logger(category: "ProgressButton")
    public enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }

    let role: ButtonRole?
    var action: () async -> Void
    var actionOptions = Set(ActionOption.allCases)
    @ViewBuilder var label: () -> LabelView

    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        @ViewBuilder label: @escaping () -> LabelView
    ) {
        self.role = role
        self.action = action
        self.actionOptions = actionOptions
        self.label = label
    }

    @State private var isDisabled = false
    @State private var isLoading = false

    public var body: some View {
        Button(role: role, action: { buttonAction() }, label: { buttonLabel })
            .disabled(isDisabled)
    }

    private func buttonAction() {
        if actionOptions.contains(.disableButton) {
            isDisabled = true
        }

        Task {
            var progressViewTask: Task<Void, Error>?
            if actionOptions.contains(.showProgressView) {
                progressViewTask = Task {
                    do {
                        try await Task.sleep(nanoseconds: 150_000_000)
                        isLoading = true
                    } catch {
                        logger.info("Timer cancelled")
                    }
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
    init(_ label: String,
         role: ButtonRole? = nil,
         actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

public extension ProgressButton where LabelView == Label<Text, Image> {
    init(_ title: String, systemImage: String,
         role: ButtonRole? = nil,
         actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
         action: @escaping () async -> Void)
    {
        self.init(role: role, action: action) {
            Label(title, systemImage: systemImage)
        }
    }
}

public extension ProgressButton where LabelView == LinkIconLabel {
    init(
        _ titleKey: String,
        systemName: String,
        color: Color,
        actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            LinkIconLabel(titleKey: titleKey, systemName: systemName, color: color)
        }
    }
}

public struct LinkIconLabel: View {
    let titleKey: String
    let systemName: String
    let color: Color

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
