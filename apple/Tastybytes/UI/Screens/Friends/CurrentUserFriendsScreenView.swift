import SwiftUI

struct CurrentUserFriendsScreenView: View {
  let client: Client
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    FriendsScreenView(client, profile: profileManager.getProfile())
  }
}
