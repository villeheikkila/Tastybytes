import SwiftUI

struct OnboardingScreen: View {
  enum Tab: Int, Identifiable, Hashable {
    case welcome, profile, avatar, permission, final

    var id: Int {
      rawValue
    }

    var next: Tab? {
      .init(rawValue: id + 1)
    }
  }

  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) private var colorScheme
  @FocusState private var focusedField: OnboardField?
  @State private var currentTab = Tab.welcome

  var body: some View {
    TabView(selection: .init(get: { currentTab }, set: { newTab in
      currentTab = newTab
      focusedField = nil
    })) {
      WelcomeOnboarding(currentTab: $currentTab) {
        withAnimation {
          currentTab = profileManager.isOnboarded ? Tab.permission : .profile
        }
      }
      .tag(Tab.welcome)
      if !profileManager.isOnboarded {
        ProfileOnboarding(focusedField: _focusedField, currentTab: $currentTab)
          .tag(Tab.profile)
        AvatarOnboarding(currentTab: $currentTab)
          .tag(Tab.avatar)
      }
      PermissionOnboarding(currentTab: $currentTab)
        .tag(Tab.permission)
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
