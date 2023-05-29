import SwiftUI

struct OnboardingScreen: View {
  enum Tab: Int, Identifiable, Hashable {
    case welcome, profile, avatar, permission, final

    var id: Int {
      rawValue
    }

    @ViewBuilder
    func view(currentTab: Binding<OnboardingScreen.Tab>, focusedField: FocusState<OnboardField?>) -> some View {
      switch self {
      case .welcome:
        WelcomeOnboarding(currentTab: currentTab)
      case .profile:
        ProfileOnboarding(focusedField: focusedField, currentTab: currentTab)
      case .avatar:
        AvatarOnboarding(currentTab: currentTab)
      case .permission:
        PermissionOnboarding(currentTab: currentTab)
      case .final:
        FinalOnboarding()
      }
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
