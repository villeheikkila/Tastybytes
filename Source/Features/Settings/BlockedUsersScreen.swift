import Components
import EnvironmentModels
import Models
import SwiftUI

struct BlockedUsersScreen: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Router.self) private var router

    var body: some View {
        List(friendEnvironmentModel.blockedUsers) { friend in
            BlockedUserListItemView(
                profile: friend.getFriend(userId: profileEnvironmentModel.profile.id),
                onUnblockUser: {
                    await friendEnvironmentModel.unblockUser(friend)
                }
            )
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await friendEnvironmentModel.refresh()
        }
        .overlay {
            ContentUnavailableView {
                Label("blockedUsers.empty.title", systemImage: "person.fill.xmark")
            } description: {
                Text("blockedUsers.empty.description")
            } actions: {
                RouterLink("blockedUsers.empty.block.label", open: .sheet(.profilePicker(mode: .block, onSubmit: {
                    router.open(.toast(.success("blockedUsers.block.success")))
                })))
            }
            .opacity(friendEnvironmentModel.blockedUsers.isEmpty ? 1 : 0)
        }
        .navigationTitle("blockedUsers.navigationTitle")
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                RouterLink("blockedUsers.block.label", systemImage: "plus", open: .sheet(.profilePicker(mode: .block, onSubmit: {
                    router.open(.toast(.success("blockedUsers.block.success")))
                })))
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }
}

struct BlockedUserListItemView: View {
    let profile: Profile
    let onUnblockUser: () async -> Void

    var body: some View {
        HStack(alignment: .center) {
            Avatar(profile: profile)
                .avatarSize(.large)
            VStack {
                HStack {
                    Text(profile.preferredName)
                    Spacer()
                    AsyncButton("blockedUsers.unblock.label", systemImage: "hand.raised.slash.fill", action: { await onUnblockUser() })
                }
            }
        }
    }
}
