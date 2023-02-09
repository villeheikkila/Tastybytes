import SwiftUI

struct OnboardTabsView: View {
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    TabView {
      WelcomeTabView()
      ProfileSettingsTabView(client)
      FinalStepView()
    }
    .tabViewStyle(.page)
  }
}
