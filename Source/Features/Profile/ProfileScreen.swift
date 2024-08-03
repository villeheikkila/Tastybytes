import Components

import Models
import Repositories
import SwiftUI

struct ProfileScreen: View {
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel

    let profile: Profile.Saved

    var body: some View {
        ProfileInnerScreen(
            profile: profile,
            isCurrentUser: profileModel.id == profile.id
        )
        .navigationTitle(profile.preferredName)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ProfileShareLinkView(profile: profile)
                if profileModel.hasNoFriendStatus(friend: profile) {
                    AsyncButton(
                        "friend.friendRequest.send.label",
                        action: { await profileModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = profileModel.isPendingCurrentUserApproval(profile) {
                    AsyncButton(
                        "friend.friendRequest.accept.label",

                        action: {
                            await profileModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
                Divider()
                ReportButton(entity: .profile(profile))
                Divider()
                AdminRouterLink(open: .sheet(.profileAdmin(id: profile.id, onDelete: { _ in
                    router.removeLast()
                })))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }
}
