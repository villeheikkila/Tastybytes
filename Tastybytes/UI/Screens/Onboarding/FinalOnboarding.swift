import SwiftUI

struct FinalOnboarding: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false

    var body: some View {
        List {}
            .modifier(OnboardingContinueButtonModifier(title: "Welcome!", onClick: {
                Task {
                    await profileManager.onboardingUpdate()
                    isOnboardedOnDevice = true
                }
            }))
    }
}
