import SwiftUI

@MainActor class SplashScreenManager: ObservableObject {
  @Published private(set) var state: SplashScreenState = .showing

  func dismiss() {
    Task {
      state = .dismissing
      try? await Task.sleep(for: Duration.seconds(1))
      self.state = .finished
    }
  }
}

extension SplashScreenManager {
  enum SplashScreenState {
    case showing, dismissing, finished
  }
}
