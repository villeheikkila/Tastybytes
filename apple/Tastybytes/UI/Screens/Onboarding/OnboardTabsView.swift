import SwiftUI

struct OnboardTabsView: View {
  @StateObject private var onboardingViewModel: OnboardingViewModel
  @Environment(\.colorScheme) private var colorScheme
  @FocusState private var focusedField: OnboardField?
  @State private var selection = Tab.welcome

  init(_ client: Client) {
    _onboardingViewModel = StateObject(wrappedValue: OnboardingViewModel(client: client))
  }

  var body: some View {
    TabView(selection: .init(get: { selection }, set: { newTab in
      selection = newTab
      focusedField = nil
    })) {
      WelcomeTab()
        .tag(Tab.welcome)
      ProfileSettingsTab(focusedField: _focusedField)
        .tag(Tab.profileSettings)
      FinalStepTab()
        .tag(Tab.final)
    }
    .environmentObject(onboardingViewModel)
    .tabViewStyle(.page)
    .onAppear {
      if colorScheme == .light {
        useDarkTabViewIndicators()
      }
    }
  }

  func useDarkTabViewIndicators() {
    UIPageControl.appearance().currentPageIndicatorTintColor = .black
    UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
  }
}

enum OnboardField {
  case username, firstName, lastName
}

extension OnboardTabsView {
  enum Tab: Int, Identifiable, Hashable {
    case welcome, profileSettings, final

    var id: Int {
      rawValue
    }
  }
}
