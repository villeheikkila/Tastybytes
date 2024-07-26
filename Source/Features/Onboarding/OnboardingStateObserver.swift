
import SwiftUI

struct OnboardingStateObserver<Content: View>: View {
    @Environment(ProfileModel.self) private var profileModel
    @ViewBuilder let content: () -> Content

    var initialOnboardingSection: OnboardingSection? {
        if !profileModel.isOnboarded {
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
