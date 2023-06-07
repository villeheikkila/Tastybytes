import SwiftUI

struct ProfileScreen: View {
  @Environment(ProfileManager.self) private var profileManager
  @State private var scrollToTop = 0

  let profile: Profile

  var body: some View {
    ProfileView(
      profile: profile,
      scrollToTop: $scrollToTop,
      isCurrentUser: profileManager.id == profile.id
    )
    .navigationTitle(profile.preferredName)
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url)
      } label: {
        Label("Options menu", systemSymbol: .ellipsis)
          .labelStyle(.iconOnly)
      }
    )
  }
}
