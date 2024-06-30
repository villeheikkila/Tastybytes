import EnvironmentModels
import SwiftUI

struct OnboardingStateObserver<Content: View>: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
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
