import SwiftUI

struct OnboardTabsView: View {
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    TabView {
      TabView {
        WelcomeTabView()
        ProfileSettingsTabView(client)
      }
    }
    .tabViewStyle(.page)
  }
}
