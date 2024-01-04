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
            ProfileShareLinkView(profile: profile)
            if !friendEnvironmentModel.isFriend(profile) {
                Menu {
                    if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                        ProgressButton(
                            "Send Friend Request",
                            action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                        )
                    } else if let friend = friendEnvironmentModel.isPendingUserApproval(profile) {
                        ProgressButton(
                            "Accept Friend Request",

                            action: {
                                await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                            }
                        )
                    }
                } label: {
                    Label("Options menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
}
