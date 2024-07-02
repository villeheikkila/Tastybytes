import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct CurrentProfileScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    var body: some View {
        ProfileView(profile: profileEnvironmentModel.profile, isCurrentUser: true)
            .navigationTitle(profileEnvironmentModel.profile.preferredName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("nameTag.show.label", systemImage: "qrcode", sheet: .nameTag(onSuccess: { profileId in
                router.fetchAndNavigateTo(repository, .profile(id: profileId))
            }))
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.title", systemImage: "gear", screen: .settings)
        }
    }
}
