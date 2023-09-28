import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

private let logger = Logger(category: "RootView")

struct AuthEventObserver: View {
    @State private var authEvent: AuthChangeEvent?
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(\.repository) private var repository

    var body: some View {
        ZStack {
            switch authEvent {
            case .signedIn:
                AuthenticatedContent()
            case .passwordRecovery:
                AuthenticationScreen(authenticationScene: .emailPassword(.resetPassword))
            case nil:
                SplashScreen()
            default:
                AuthenticationScreen()
            }
            if !isMac(), splashScreenEnvironmentModel.state != .finished {
                SplashScreen()
            }
        }
        .onOpenURL { url in
            Task {
                await loadSessionFromURL(url: url)
            }
        }
        .task {
            for await authEventChange in repository.authEvent {
                withAnimation {
                    authEvent = authEventChange
                }
                switch authEvent {
                case .signedIn:
                    await profileEnvironmentModel.initialize()
                    guard let deviceTokenForPusNotifications else { return }
                    await notificationEnvironmentModel.refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
                default:
                    break
                }
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
