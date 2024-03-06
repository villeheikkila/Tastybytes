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
    let task: @Sendable () async -> Void

    init(
        id: ID,
        priority: TaskPriority = .userInitiated,
        milliseconds: Int = 0,
        task: @Sendable @escaping () async -> Void
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
        task: @Sendable @escaping () async -> Void
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

struct DetectOrientation: ViewModifier {
    @Binding var isPortrait: Bool

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                isPortrait = isPortrait(orientation: UIDevice.current.orientation)
            }
    }

    func isPortrait(orientation: UIDeviceOrientation) -> Bool {
        switch orientation {
        case .portrait, .portraitUpsideDown:
            true
        default:
            false
        }
    }
}

public extension View {
    func detectOrientation(_ isPortrait: Binding<Bool>) -> some View {
        modifier(DetectOrientation(isPortrait: isPortrait))
    }
}

public struct AlertError: Identifiable, Equatable {
    public let id: UUID
    public let title: LocalizedStringKey

    public init() {
        title = "Unexpected error occured"
        id = UUID()
    }

    public init(title: LocalizedStringKey) {
        self.title = title
        id = UUID()
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
                Alert(title: Text(error.title))
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
    func initialTask(_ action: @escaping @MainActor @Sendable () async -> Void) -> some View {
        modifier(InitialTask(action: action))
    }
}

private struct InitialTask: ViewModifier {
    @State private var isInitial = true
    let action: @MainActor @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.task {
            guard isInitial else { return }
            isInitial = false
            await action()
        }
    }
}
