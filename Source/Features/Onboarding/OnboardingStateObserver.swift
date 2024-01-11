import EnvironmentModels
import SwiftUI

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
        if let initialOnboardingSection {
            OnboardingScreen(initialTab: initialOnboardingSection)
        } else {
            content()
        }
    }
}

@MainActor
struct ProfileStateObserver<Content: View>: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch profileEnvironmentModel.profileState {
        case .initialized:
            content()
        case .uninitialized:
            EmptyView()
        case .error:
            // TODO: Add proper error page
            AppUnexpectedErrorState()
        }
    }
}
