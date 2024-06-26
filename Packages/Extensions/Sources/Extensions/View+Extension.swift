import SwiftUI

public extension View {
    @ViewBuilder
    func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

public extension View {
    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
}

public struct RoundedCorner: Shape {
    var radius: Double = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public extension View {
    func cornerRadius(_ radius: Double, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

public extension View {
    func onChange<Value>(
        of value: Value,
        debounceTime: TimeInterval,
        perform action: @escaping (_ newValue: Value) -> Void
    ) -> some View where Value: Equatable {
        modifier(DebouncedChangeViewModifier(trigger: value, debounceTime: debounceTime, action: action))
    }
}

struct DebouncedTaskViewModifier<ID: Equatable>: ViewModifier {
    let id: ID
    let priority: TaskPriority
    let milliseconds: Int
    let task: () async -> Void

    init(
        id: ID,
        priority: TaskPriority = .userInitiated,
        milliseconds: Int = 0,
        task: @escaping () async -> Void
    ) {
        self.id = id
        self.priority = priority
        self.milliseconds = milliseconds
        self.task = task
    }

    func body(content: Content) -> some View {
        content.task(id: id, priority: priority) {
            do {
                try await Task.sleep(for: .milliseconds(milliseconds))
                await task()
            } catch {}
        }
    }
}

public extension View {
    func task(
        id: some Equatable,
        priority: TaskPriority = .userInitiated,
        milliseconds: Int = 0,
        task: @escaping () async -> Void
    ) -> some View {
        modifier(
            DebouncedTaskViewModifier(
                id: id,
                priority: priority,
                milliseconds: milliseconds,
                task: task
            )
        )
    }
}

private struct DebouncedChangeViewModifier<Value>: ViewModifier where Value: Equatable {
    let trigger: Value
    let debounceTime: TimeInterval
    let action: (Value) -> Void

    @State private var debouncedTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content.onChange(of: trigger) { _, value in
            debouncedTask?.cancel()
            debouncedTask = Task.delayed(seconds: debounceTime) { @MainActor in
                action(value)
            }
        }
    }
}

public extension Task {
    @discardableResult
    static func delayed(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async -> Void
    ) -> Self where Success == Void, Failure == Never {
        Self {
            do {
                try await Task<Never, Never>.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                await operation()
            } catch {}
        }
    }
}

public struct AlertError: Identifiable, Equatable {
    public let id: UUID
    let title: Text
    let message: Text?
    let retryLabel: LocalizedStringKey?
    let retry: (() -> Void)?

    public init() {
        title = Text("Unexpected error occured")
        id = UUID()
        message = nil
        retry = nil
        retryLabel = nil
    }

    public init(title: LocalizedStringKey, message: Text? = nil, retryLabel: LocalizedStringKey? = nil, retry: (() -> Void)? = nil) {
        id = UUID()
        self.title = Text(title)
        self.message = message
        self.retry = retry
        self.retryLabel = retryLabel
    }

    var alert: Alert {
        if let retry {
            .init(title: title, message: message, primaryButton: .default(Text(retryLabel ?? "Retry"), action: retry), secondaryButton: .cancel())
        } else {
            .init(title: title, message: message)
        }
    }

    public static func == (lhs: AlertError, rhs: AlertError) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.message == rhs.message
    }
}

struct AlertErrorModifier: ViewModifier {
    @Binding var alertError: AlertError?

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(.error, trigger: alertError) { _, newValue in
                newValue != nil
            }
            .alert(item: $alertError) { error in
                error.alert
            }
    }
}

public extension View {
    func alertError(_ alertError: Binding<AlertError?>) -> some View {
        modifier(AlertErrorModifier(alertError: alertError))
    }
}

public extension View {
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
}

public extension View {
    func initialTask(_ action: @escaping () async -> Void) -> some View {
        modifier(InitialTask(action: action))
    }
}

private struct InitialTask: ViewModifier {
    @State private var isInitial = true
    let action: () async -> Void

    func body(content: Content) -> some View {
        content.task {
            guard isInitial else { return }
            isInitial = false
            await action()
        }
    }
}

public struct DismissKeyboardOnBackgroundTapModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

public extension View {
    func dismissKeyboardOnBackgroundTap() -> some View {
        modifier(DismissKeyboardOnBackgroundTapModifier())
    }
}
