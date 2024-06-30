import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct CurrentProfileScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Binding var scrollToTop: Int

    var body: some View {
        ProfileView(profile: profileEnvironmentModel.profile, scrollToTop: $scrollToTop, isCurrentUser: true)
            .navigationTitle(profileEnvironmentModel.profile.preferredName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("nameTag.show.label", systemImage: "qrcode", action: {
                router.openRootSheet(.nameTag(onSuccess: { profileId in
                    router.fetchAndNavigateTo(repository, .profile(id: profileId))
                }))
            })
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.title", systemImage: "gear", screen: .settings)
        }
    }
}
