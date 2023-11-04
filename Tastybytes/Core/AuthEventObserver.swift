import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "RootView")

struct AuthEventObserver: View {
    @State private var authState: AuthState?
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(\.repository) private var repository

    var body: some View {
        ZStack {
            switch authState {
            case .authenticated:
                AuthenticatedContent()
            case .unauthenticated:
                AuthenticationScreen(authenticationScene: .emailPassword(.resetPassword))
                if !isMac(), splashScreenEnvironmentModel.state != .finished {
                    SplashScreen()
                }
            case .none:
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
            Task {
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
        }
        .onOpenURL { url in
            Task {
                await loadSessionFromURL(url: url)
            }
        }
    }

    func loadSessionFromURL(url: URL) async {
        let result = await repository.auth.signInFromUrl(url: url)
        if case let .failure(error) = result {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }
}
