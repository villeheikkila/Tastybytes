import SwiftUI

struct ProfileScreenView: View {
  let client: Client
  let profile: Profile
  @State private var scrollToTop = 0

  init(_ client: Client, profile: Profile) {
    self.client = client
    self.profile = profile
  }

  var body: some View {
    ProfileView(client, profile: profile, scrollToTop: $scrollToTop)
      .navigationTitle(profile.preferredName)
      .navigationBarItems(
        trailing: Menu {
          ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url)
        } label: {
          Image(systemName: "ellipsis")
        }
      )
  }
}
