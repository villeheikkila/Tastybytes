import Models
import Repositories
import SwiftUI

struct CurrentProfileScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileManager.self) private var profileManager
    @Binding var scrollToTop: Int

    var body: some View {
        ProfileView(profile: profileManager.profile, scrollToTop: $scrollToTop, isCurrentUser: true)
            .navigationTitle(profileManager.profile.preferredName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("Show name tag", systemSymbol: .qrcode, sheet: .nameTag(onSuccess: { profileId in
                router.fetchAndNavigateTo(repository, .profile(id: profileId))
            }))
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("Settings page", systemSymbol: .gear, screen: .settings)
        }
    }
}
