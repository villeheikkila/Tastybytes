
import Models
import Repositories
import SwiftUI

struct CurrentProfileScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        ProfileView(profile: profileModel.profile, isCurrentUser: true)
            .navigationTitle(profileModel.profile.preferredName)
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
