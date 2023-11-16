import Extensions
import Observation
import OSLog
import SwiftUI

@Observable
public final class SplashScreenEnvironmentModel {
    private let logger = Logger(category: "SplashScreenEnvironmentModel")

    public init() {}

    public enum SplashScreenState {
        case showing, dismissing, finished
    }

    public var state: SplashScreenState = .showing

    public func dismiss() async {
        if state == .showing {
            logger.info("Dismissing splash screen")
            state = .dismissing
            try? await Task.sleep(for: Duration.seconds(0.5))
            state = .finished
        }
    }
}
