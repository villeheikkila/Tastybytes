import SwiftUI

struct OnboardingScreen: View {
  enum Tab: Int, Identifiable, Hashable {
    case welcome, profile, avatar, pushNotification, final

    var id: Int {
      rawValue
    }

    var next: Tab? {
      .init(rawValue: id + 1)
    }
  }

  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @Environment(\.colorScheme) private var colorScheme
  @FocusState private var focusedField: OnboardField?
  @State private var currentTab = Tab.welcome

  var body: some View {
    TabView(selection: .init(get: { currentTab }, set: { newTab in
      currentTab = newTab
      focusedField = nil
    })) {
      WelcomeOnboarding(currentTab: $currentTab)
        .tag(Tab.welcome)
      ProfileOnboarding(focusedField: _focusedField, currentTab: $currentTab)
        .tag(Tab.profile)
      AvatarOnboarding(currentTab: $currentTab)
        .tag(Tab.avatar)
      PushNotificationOnboarding(currentTab: $currentTab)
        .tag(Tab.pushNotification)
      FinalOnboarding()
        .tag(Tab.final)
    }
    .tabViewStyle(.page)
    .indexViewStyle(.page(backgroundDisplayMode: .never))
    .task {
      await splashScreenManager.dismiss()
    }
  }
}

enum OnboardField {
  case username, firstName, lastName
}
