import Logging
import SwiftUI
import TipKit

struct ApplicationStateObserver<Content: View>: View {
    @Environment(AppModel.self) private var appModel
    @Environment(ProfileModel.self) private var profileModel
    @Environment(LocationModel.self) private var locationModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        StateContentView(
            state: .init(appState: appModel.state, profileState: profileModel.state, isOnboarded: profileModel.isOnboarded),
            content: content
        )
        .task {
            try? Tips.configure([.displayFrequency(.daily)])
        }
        .task {
            await appModel.initialize()
        }
        .task {
            await profileModel.listenToAuthState()
        }
        .task {
            locationModel.updateLocationAuthorizationStatus()
        }
        .onNotification(named: NSNotification.Name(rawValue: "PushNotificationReceived"), perform: { notification in
            guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                  let unreadCount = aps["badge"] as? Int else { return }
            profileModel.unreadCount = unreadCount
        })
    }
}

private struct StateContentView<Content: View>: View, Equatable {
    @Environment(AppModel.self) private var appModel
    private let logger = Logger(label: "ApplicationStateObserver")
    let state: ApplicationState
    @ViewBuilder let content: () -> Content

    nonisolated static func == (lhs: StateContentView<Content>, rhs: StateContentView<Content>) -> Bool {
        lhs.state == rhs.state
    }

    var body: some View {
        switch state {
        case .operational:
            content()
                .transition(.opacity)
        case .loading:
            SplashScreenView()
                .transition(.opacity)
        case let .appError(error):
            AppErrorStateView(error: error)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case let .profileError(error):
            ProfileErrorStateView(error: error)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .outdatedVersion:
            AppUnsupportedVersionState()
                .transition(.scale.combined(with: .opacity))
        case .maintenance:
            AppUnderMaintenanceState()
                .transition(.scale.combined(with: .opacity))
        case .requiresOnboarding:
            RouterProvider(enableRoutingFromURLs: false) {
                OnboardingScreen()
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

private enum ApplicationState: Equatable {
    case operational
    case loading
    case appError(Error)
    case profileError(Error)
    case outdatedVersion
    case maintenance
    case requiresOnboarding

    init(appState: AppState, profileState: ProfileState, isOnboarded: Bool) {
        self = switch (appState, profileState, isOnboarded) {
        case (.operational, .populated, true):
            .operational
        case (.loading, _, _), (.operational, .loading, _):
            .loading
        case let (.error(error), _, _):
            .appError(error)
        case let (.operational, .error(error), _):
            .profileError(error)
        case (.tooOldAppVersion, _, _):
            .outdatedVersion
        case (.underMaintenance, _, _):
            .maintenance
        case (.operational, .unauthenticated, _), (.operational, .populated, false):
            .requiresOnboarding
        }
    }

    static func == (lhs: ApplicationState, rhs: ApplicationState) -> Bool {
        switch (lhs, rhs) {
        case (.operational, .operational),
             (.loading, .loading),
             (.outdatedVersion, .outdatedVersion),
             (.maintenance, .maintenance),
             (.requiresOnboarding, .requiresOnboarding):
            true

        case let (.appError(lhsErrors), .appError(rhsErrors)),
             let (.profileError(lhsErrors), .profileError(rhsErrors)):
            lhsErrors.localizedDescription == rhsErrors.localizedDescription

        default:
            false
        }
    }
}
