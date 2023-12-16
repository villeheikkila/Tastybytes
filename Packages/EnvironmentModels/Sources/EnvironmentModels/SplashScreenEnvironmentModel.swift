import Extensions
import OSLog
import SwiftUI

@Observable
public final class SplashScreenEnvironmentModel {
    private let logger = Logger(category: "SplashScreenEnvironmentModel")
    private var task: Task<Void, Never>?
    public var state: SplashScreenState = .showing

    public init() {}

    public enum SplashScreenState {
        case showing, dismissing, finished
    }

    @MainActor
    public func dismiss() {
        guard state == .showing, task == nil else { return }
        task = Task {
            defer { task = nil }
            logger.info("Dismissing splash screen")
            state = .dismissing
            try? await Task.sleep(for: Duration.seconds(0.5))
            state = .finished
        }
    }
}

struct DismissSplashScreenModifier: ViewModifier {
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel

    func body(content: Content) -> some View {
        content.onAppear {
            splashScreenEnvironmentModel.dismiss()
        }
    }
}

public extension View {
    func dismissSplashScreen() -> some View {
        modifier(DismissSplashScreenModifier())
    }
}
