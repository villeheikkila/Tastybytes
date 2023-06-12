import SwiftUI

struct LocalizedAlertError: LocalizedError {
  let underlyingError: LocalizedError
  var errorDescription: String? {
    underlyingError.errorDescription
  }

  var recoverySuggestion: String? {
    underlyingError.recoverySuggestion
  }

  init?(error: Error?) {
    guard let localizedError = error as? LocalizedError else { return nil }
    underlyingError = localizedError
  }
}

extension View {
  func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
    let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
    return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
      Button(buttonTitle) {
        error.wrappedValue = nil
      }
    } message: { error in
      Text(error.recoverySuggestion.orEmpty)
    }
  }
}

extension View {
  @ViewBuilder
  func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
    if condition() {
      transform(self)
    } else {
      self
    }
  }
}

struct RoundedCorner: Shape {
  var radius: Double = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

extension View {
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

extension View {
  func detectOrientation(_ orientation: Binding<UIDeviceOrientation>) -> some View {
    modifier(DetectOrientation(orientation: orientation))
  }
}

struct DetectOrientation: ViewModifier {
  @Binding var orientation: UIDeviceOrientation

  func body(content: Content) -> some View {
    content
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
        let fallback = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? UIDeviceOrientation
          .portrait : UIDeviceOrientation.landscapeRight
        orientation = UIDevice.current.orientation == .unknown ? fallback : UIDevice.current.orientation
      }
  }
}
