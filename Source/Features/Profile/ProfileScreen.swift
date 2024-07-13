import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProfileScreen: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    let profile: Profile

    var body: some View {
        ProfileView(
            profile: profile,
            isCurrentUser: profileEnvironmentModel.id == profile.id
        )
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
        .navigationTitle(profile.preferredName)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ProfileShareLinkView(profile: profile)
                if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                    AsyncButton(
                        "friend.friendRequest.send.label",
                        action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendEnvironmentModel.isPendingCurrentUserApproval(profile) {
                    AsyncButton(
                        "friend.friendRequest.accept.label",

                        action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
                Divider()
                ReportButton(entity: .profile(profile))
                Divider()
                AdminRouterLink(open: .sheet(.profileAdmin(profile: profile)))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }
}
