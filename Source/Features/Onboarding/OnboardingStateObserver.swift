import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

@MainActor
struct OnboardingStateObserver<Content: View>: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel

    @ViewBuilder let content: () -> Content

    var initialOnboardingSection: OnboardingSection? {
        if !profileEnvironmentModel.isOnboarded {
            return .profile
        }
        if permissionEnvironmentModel.pushNotificationStatus == .notDetermined {
            return .notifications
        }
        if locationEnvironmentModel.locationsStatus == .notDetermined {
            return .location
        }
        return nil
    }

    var body: some View {
        if !profileEnvironmentModel.isLoggedIn {
            EmptyView()
        } else if let initialOnboardingSection {
            OnboardingScreen(initialTab: initialOnboardingSection)
        } else {
            content()
        }
    }
}
