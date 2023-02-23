import SwiftUI

struct ProfileScreenView: View {
  let client: Client
  let profile: Profile
  @State private var scrollToTop = 0
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client, profile: Profile) {
    self.client = client
    self.profile = profile
  }

  var body: some View {
    ProfileView(
      client,
      profile: profile,
      scrollToTop: $scrollToTop,
      isCurrentUser: profileManager.getId() == profile.id
    )
    .navigationTitle(profile.preferredName)
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url)
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    )
  }
}
