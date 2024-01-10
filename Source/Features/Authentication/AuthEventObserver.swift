import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AuthEventObserver<Authenticated: View, Unauthenticated: View>: View {
    private let logger = Logger(category: "AuthEventObserver")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(\.repository) private var repository
    @State private var loadSessionFromUrlTask: Task<Void, Never>?

    @ViewBuilder let authenticated: () -> Authenticated
    @ViewBuilder let unauthenticated: () -> Unauthenticated

    var body: some View {
        VStack {
            switch profileEnvironmentModel.authState {
            case .authenticated:
                authenticated()
            case .unauthenticated:
                unauthenticated()
            case .none:
                EmptyView()
            }
        }
        .task(id: profileEnvironmentModel.authState) {
            if case .authenticated = profileEnvironmentModel.authState {
                await profileEnvironmentModel.initialize()
                guard let deviceTokenForPusNotifications = await deviceTokenActor.deviceTokenForPusNotifications else { return }
                await notificationEnvironmentModel
                    .refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
            }
        }
        .task {
            await profileEnvironmentModel.listenToAuthState()
        }
        .onOpenURL { url in
            loadSessionFromUrlTask = Task {
                await loadSessionFromURL(url: url)
            }
        }
        .onDisappear {
            loadSessionFromUrlTask?.cancel()
        }
    }

    func loadSessionFromURL(url: URL) async {
        let result = await repository.auth.signInFromUrl(url: url)
        if case let .failure(error) = result {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }
}
