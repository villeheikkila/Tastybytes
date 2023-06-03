import SwiftUI

struct FinalOnboarding: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
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
