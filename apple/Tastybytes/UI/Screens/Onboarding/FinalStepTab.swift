import SwiftUI

struct FinalStepTab: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager

  var body: some View {
    List {}
      .modifier(OnboardingContinueButtonModifier(title: "Welcome!",
                                                 onClick: {
                                                   Task { await profileManager.onboardingUpdate() }
                                                 }))
  }
}
