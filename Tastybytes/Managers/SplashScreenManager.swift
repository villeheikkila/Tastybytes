import Observation
import SwiftUI

@Observable
final class SplashScreenManager {
    enum SplashScreenState {
        case showing, dismissing, finished
    }

    var state: SplashScreenState = .showing

    func dismiss() async {
        if state == .showing {
            state = .dismissing
            try? await Task.sleep(for: Duration.seconds(0.5))
            state = .finished
        }
    }
}
