import SwiftUI

struct CurrentProfileScreen: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding var scrollToTop: Int

  var body: some View {
    ProfileView(profile: profileManager.profile, scrollToTop: $scrollToTop, isCurrentUser: true)
      .navigationTitle(profileManager.profile.preferredName)
      .navigationBarTitleDisplayMode(.inline)
  }
}
