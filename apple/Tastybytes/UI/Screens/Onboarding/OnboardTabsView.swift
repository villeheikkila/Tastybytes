import SwiftUI

struct OnboardTabsView: View {
  @StateObject private var onboardingViewModel: OnboardingViewModel

  init(_ client: Client) {
    _onboardingViewModel = StateObject(wrappedValue: OnboardingViewModel(client: client))
  }

  var body: some View {
    TabView {
      WelcomeTab()
      ProfileSettingsTab()
      FinalStepTab()
    }
    .environmentObject(onboardingViewModel)
    .tabViewStyle(.page)
  }
}
