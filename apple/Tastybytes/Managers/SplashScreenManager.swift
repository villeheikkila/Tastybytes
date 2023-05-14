import SwiftUI

@MainActor
final class SplashScreenManager: ObservableObject {
  enum SplashScreenState {
    case showing, dismissing, finished
  }

  @Published private(set) var state: SplashScreenState = .showing

  func dismiss() async {
    if state == .showing {
      state = .dismissing
      try? await Task.sleep(for: Duration.seconds(0.5))
      state = .finished
    }
  }
}
