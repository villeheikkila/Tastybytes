import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AuthEventObserver<Authenticated: View, Unauthenticated: View, Loading: View>: View {
    private let logger = Logger(category: "AuthEventObserver")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(\.repository) private var repository
    @State private var authState: AuthState?
    @State private var task: Task<Void, Never>?

    @ViewBuilder let authenticated: () -> Authenticated
    @ViewBuilder let unauthenticated: () -> Unauthenticated
    @ViewBuilder let loading: () -> Loading

    var body: some View {
        Group {
            switch authState {
            case .authenticated:
                authenticated()
            case .unauthenticated:
                unauthenticated()
            case .none:
                loading()
            }
        }
        .onChange(of: authState) {
            if case .authenticated = authState {
                Task {
                    await profileEnvironmentModel.initialize()
                    guard let deviceTokenForPusNotifications = await deviceTokenActor.deviceTokenForPusNotifications else { return }
                    await notificationEnvironmentModel
                        .refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
                }
            }
        }
        .task {
            for await state in await repository.auth.authStateListener() {
                authState = state
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
