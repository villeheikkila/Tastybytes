import Components

import Models
import SwiftUI

struct BlockedUsersScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(Router.self) private var router

    var body: some View {
        List(profileModel.blockedUsers) { friend in
            BlockedUserListItemView(
                profile: friend.getFriend(userId: profileModel.profile.id),
                onUnblockUser: {
                    await profileModel.unblockUser(friend)
                }
            )
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await profileModel.refreshFriends()
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
            .opacity(profileModel.blockedUsers.isEmpty ? 1 : 0)
        }
        .navigationTitle("blockedUsers.navigationTitle")
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
    let profile: Profile.Saved
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
