import SwiftUI

class SplashScreenManager: ObservableObject { @MainActor
  @Published private(set) var state: SplashScreenState = .showing

  @MainActor
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
    case showing
    case dismissing
    case finished
  }
}
