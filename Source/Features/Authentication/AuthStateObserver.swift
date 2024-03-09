import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct AuthStateObserver<Authenticated: View>: View {
    private let logger = Logger(category: "AuthStateObserver")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var loadSessionFromUrlTask: Task<Void, Never>?
    @ViewBuilder let authenticated: () -> Authenticated

    var body: some View {
        VStack {
            switch profileEnvironmentModel.authState {
            case .authenticated:
                authenticated()
            case .unauthenticated:
                AuthenticationScreen()
            case .none:
                EmptyView()
            }
        }
        .onDisappear {
            loadSessionFromUrlTask?.cancel()
        }
    }
}
