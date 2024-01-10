import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AuthStateObserver<Authenticated: View, Unauthenticated: View>: View {
    private let logger = Logger(category: "AuthStateObserver")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
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
