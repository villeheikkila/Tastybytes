import SwiftUI

struct ProfileScreenView: View {
  @State private var scrollToTop = 0

  let profile: Profile

  var body: some View {
    ProfileView(profile: profile, scrollToTop: $scrollToTop)
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
