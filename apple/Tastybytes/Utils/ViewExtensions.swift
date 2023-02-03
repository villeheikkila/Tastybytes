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

public extension View {
  func fullBackground(imageName: String) -> some View {
    background(
      Image(imageName)
        .resizable()
        .scaledToFill()
        .edgesIgnoringSafeArea(.all)
    )
  }
}

extension View {
  @ViewBuilder func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
    if condition() {
      transform(self)
    } else {
      self
    }
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
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
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}
