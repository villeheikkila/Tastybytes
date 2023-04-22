import SwiftUI

struct ProfileTab: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop = 0
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      CurrentProfileScreen(scrollToTop: $scrollToTop)
        .toolbar {
          ToolbarItemGroup(placement: .navigationBarLeading) {
            RouterLink("Show name tag", systemImage: "qrcode", sheet: .nameTag(onSuccess: { profileId in
              router.fetchAndNavigateTo(repository, NavigatablePath.profile(id: profileId))
            }))
          }
          ToolbarItemGroup(placement: .navigationBarTrailing) {
            RouterLink("Settings page", systemImage: "gear", screen: .settings)
          }
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .profile {
            if router.path.isEmpty {
              scrollToTop += 1
            } else {
              router.reset()
            }
            resetNavigationOnTab = nil
          }
        }
    }
  }
}
