import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthEventObserver: View {
    private let logger = Logger(category: "AuthEventObserver")
    @State private var authState: AuthState?
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(\.repository) private var repository
    @State private var task: Task<Void, Never>?

    var body: some View {
        ZStack {
            switch authState {
            case .authenticated:
                AuthenticatedContent()
            case .unauthenticated:
                AuthenticationScreen()
            case .none:
                SplashScreen()
            }
            if !isMac(), splashScreenEnvironmentModel.state != .finished {
                SplashScreen()
            }
        }
        .onChange(of: authState) {
            if case .authenticated = authState {
                Task {
                    await profileEnvironmentModel.initialize()
                    guard let deviceTokenForPusNotifications else { return }
                    await notificationEnvironmentModel
                        .refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
                }
            }
        }
        .task {
            for await state in await repository.auth.authStateListener() {
                await MainActor.run {
                    self.authState = state
                }
                logger.debug("auth state changed: \(String(describing: state))")
                if Task.isCancelled {
                    return
                }
            }
        }
        .onOpenURL { url in
            task = Task {
                await loadSessionFromURL(url: url)
            }
        }
        .onDisappear {
            task?.cancel()
        }
    }

    func loadSessionFromURL(url: URL) async {
        let result = await repository.auth.signInFromUrl(url: url)
        if case let .failure(error) = result {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }
}
