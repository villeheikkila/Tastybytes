import SwiftUI

struct OnboardTabsView: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @Environment(\.colorScheme) private var colorScheme
  @FocusState private var focusedField: OnboardField?
  @State private var currentTab = Tab.welcome

  var body: some View {
    TabView(selection: .init(get: { currentTab }, set: { newTab in
      currentTab = newTab
      focusedField = nil
    })) {
      WelcomeTab(currentTab: $currentTab)
        .tag(Tab.welcome)
      FillProfileTab(focusedField: _focusedField, currentTab: $currentTab)
        .tag(Tab.profile)
      AvatarTab(currentTab: $currentTab)
        .tag(Tab.avatar)
      FinalStepTab()
        .tag(Tab.final)
    }
    .tabViewStyle(.page)
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .task {
      await splashScreenManager.dismiss()
    }
  }
}

enum OnboardField {
  case username, firstName, lastName
}

extension OnboardTabsView {
  enum Tab: Int, Identifiable, Hashable {
    case welcome, profile, avatar, final

    var id: Int {
      rawValue
    }
  }
}
