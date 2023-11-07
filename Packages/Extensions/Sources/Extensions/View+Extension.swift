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
        return frame(width: size.width, height: size.height)
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

public extension View {
    func detectOrientation(_ isPortrait: Binding<Bool>) -> some View {
        modifier(DetectOrientation(isPortrait: isPortrait))
    }
}

public struct DetectOrientation: ViewModifier {
    @Binding var isPortrait: Bool

    public func body(content: Content) -> some View {
        content.onAppear {
            #if os(iOS)
                NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                    .sink { _ in
                        let isCurrentlyPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
                        isPortrait = UIDevice.current
                            .orientation == .unknown ? isCurrentlyPortrait :
                            (UIDevice.current.orientation == .portrait || UIDevice.current
                                .orientation == .portraitUpsideDown)
                    }
            #elseif os(macOS) || os(watchOS) || os(tvOS)
                isPortrait = false
            #endif
        }
    }
}

public struct AlertError: Identifiable, Equatable {
    public let id: UUID
    public let title: String

    public init() {
        title = "Unexpected error occured"
        id = UUID()
    }

    public init(title: String) {
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
