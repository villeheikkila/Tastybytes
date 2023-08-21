import Models
import SwiftUI

struct BlockedUsersScreen: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

    var body: some View {
        List {
            ForEach(friendEnvironmentModel.blockedUsers) { friend in
                BlockedUserListItemView(profile: friend.getFriend(userId: profileEnvironmentModel.profile.id), onUnblockUser: {
                    await friendEnvironmentModel.unblockUser(friend)
                })
            }
        }
        .listStyle(.insetGrouped)
        .background {
            if friendEnvironmentModel.blockedUsers.isEmpty {
                ContentUnavailableView {
                    Label("You haven't blocked any users", systemSymbol: .personFillXmark)
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await friendEnvironmentModel.refresh(withFeedback: true)
        }
        #endif
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                RouterLink("Show block user sheet", systemSymbol: .plus, sheet: .userSheet(mode: .block, onSubmit: {
                    feedbackEnvironmentModel.toggle(.success("User blocked"))
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
