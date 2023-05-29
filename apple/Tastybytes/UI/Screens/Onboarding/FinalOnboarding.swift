import SwiftUI

struct FinalOnboarding: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @AppStorage("is_current_device_onboarded") private var isCurrentDeviceOnboarded = false

  var body: some View {
    List {}
      .modifier(OnboardingContinueButtonModifier(title: "Welcome!", onClick: {
        Task {
          await profileManager.onboardingUpdate()
          isCurrentDeviceOnboarded = true
        }
      }))
  }
}
