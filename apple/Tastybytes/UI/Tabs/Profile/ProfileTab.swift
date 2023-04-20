import Charts
import PhotosUI
import SwiftUI

struct ProfileTab: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var scrollToTop = 0
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      ProfileView(profile: profileManager.profile, scrollToTop: $scrollToTop, isCurrentUser: true)
        .navigationTitle(profileManager.profile.preferredName)
        .navigationBarTitleDisplayMode(.inline)
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
