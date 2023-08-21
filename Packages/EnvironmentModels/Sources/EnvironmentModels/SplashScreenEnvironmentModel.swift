import Observation
import SwiftUI

@Observable
public final class SplashScreenEnvironmentModel {
    public init() {}

    public enum SplashScreenState {
        case showing, dismissing, finished
    }

    public var state: SplashScreenState = .showing

    public func dismiss() async {
        if state == .showing {
            state = .dismissing
            try? await Task.sleep(for: Duration.seconds(0.5))
            state = .finished
        }
    }
}
