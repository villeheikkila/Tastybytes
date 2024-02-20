import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct BlockedUsersScreen: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var sheet: Sheet?

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
        .overlay {
            ContentUnavailableView {
                Label("blockedUsers.empty.title", systemImage: "person.fill.xmark")
            } description: {
                Text("blockedUsers.empty.description")
            } actions: {
                RouterLink("blockedUsers.empty.block.label", sheet: .userSheet(mode: .block, onSubmit: {
                    feedbackEnvironmentModel.toggle(.success("blockedUsers.block.success"))
                }))
            }
            .opacity(friendEnvironmentModel.blockedUsers.isEmpty ? 1 : 0)
        }
        .navigationTitle("blockedUsers.navigationTitle")
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .refreshable {
            await friendEnvironmentModel.refresh()
        }
        .sheets(item: $sheet)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                Button("blockedUsers.block.label", systemImage: "plus", action: { sheet = .userSheet(mode: .block, onSubmit: {
                    feedbackEnvironmentModel.toggle(.success("blockedUsers.block.success"))
                }) })
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }
}

struct BlockedUserListItemView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
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
                    ProgressButton("blockedUsers.unblock.label", systemImage: "hand.raised.slash.fill", action: { await onUnblockUser() })
                }
            }
        }
    }
}
