import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct ProfileScreen: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var scrollToTop = 0

    let profile: Profile

    var body: some View {
        ProfileView(
            profile: profile,
            scrollToTop: $scrollToTop,
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
                ReportButton(entity: .profile(profile))
                if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                    ProgressButton(
                        "friend.friendRequest.send.label",
                        action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendEnvironmentModel.isPendingUserApproval(profile) {
                    ProgressButton(
                        "friend.friendRequest.accept.label",

                        action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }
}
