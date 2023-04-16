import SwiftUI

struct ProfileScreen: View {
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop = 0

  let profile: Profile

  var body: some View {
    ProfileView(
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
