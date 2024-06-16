import EnvironmentModels
import SwiftUI

@MainActor
struct OnboardingStateObserver<Content: View>: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @AppStorage(.notificationOnboardingSectionSkipped) private var notificationOnboardingSectionSkipped = false
    @AppStorage(.locationOnboardingSectionSkipped) private var locationOnboardingSectionSkipped = false

    @ViewBuilder let content: () -> Content

    var initialOnboardingSection: OnboardingSection? {
        if !profileEnvironmentModel.isOnboarded {
            return .profile
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
