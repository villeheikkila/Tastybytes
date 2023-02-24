import SwiftUI

struct CurrentUserFriendsScreen: View {
  let client: Client
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    FriendsScreen(client, profile: profileManager.getProfile())
  }
}
