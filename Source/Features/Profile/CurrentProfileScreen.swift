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
            RouterLink("nameTag.show.label", systemImage: "qrcode", open: .sheet(.nameTag(onSuccess: { profileId in
                router.open(.screen(.profileById(profileId)))
            })))
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.title", systemImage: "gear", open: .sheet(.settings))
        }
    }
}
