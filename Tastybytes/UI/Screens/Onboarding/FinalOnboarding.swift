import SwiftUI

struct FinalOnboarding: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false

    var body: some View {
        List {}
            .modifier(OnboardingContinueButtonModifier(title: "Welcome!", onClick: {
                Task {
                    await profileEnvironmentModel.onboardingUpdate()
                    isOnboardedOnDevice = true
                }
            }))
    }
}
