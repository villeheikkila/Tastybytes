import SwiftUI

struct BlockedUsersScreen: View {
    @Environment(FriendManager.self) private var friendManager
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var showUserSearchSheet = false

    var body: some View {
        List {
            if friendManager.blockedUsers.isEmpty {
                Text("You haven't blocked any users")
            }
            ForEach(friendManager.blockedUsers) { friend in
                BlockedUserListItemView(profile: friend.getFriend(userId: profileManager.profile.id), onUnblockUser: {
                    await friendManager.unblockUser(friend)
                })
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Blocked Users")
        .toolbar {
            toolbarContent
        }
        .navigationBarTitleDisplayMode(.inline)
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await friendManager.refresh(withFeedback: true)
            }
        #endif
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                RouterLink("Show block user sheet", systemSymbol: .plus, sheet: .userSheet(mode: .block, onSubmit: {
                    feedbackManager.toggle(.success("User blocked"))
                }))
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
            AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
            VStack {
                HStack {
                    Text(profile.preferredName)
                    Spacer()
                    ProgressButton("Unblock", systemSymbol: .handRaisedSlashFill, action: { await onUnblockUser() })
                }
            }
        }
    }
}
