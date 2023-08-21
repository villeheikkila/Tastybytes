import Models
import SwiftUI

struct FriendSheet: View {
    @Binding var taggedFriends: [Profile]
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(friendEnvironmentModel.acceptedFriends) { friend in
            HStack {
                AvatarView(avatarUrl: friend.avatarUrl, size: 32, id: friend.id)
                Text(friend.preferredName)
                Spacer()
                Label("Tag friend", systemSymbol: .checkmark)
                    .labelStyle(.iconOnly)
                    .opacity(taggedFriends.contains(friend) ? 1 : 0)
            }
            .accessibilityAddTraits(.isButton)
            .contentShape(Rectangle())
            .onTapGesture {
                toggleFriend(friend: friend)
            }
        }
        .buttonStyle(.plain)
        .navigationTitle("Friends")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }

    private func toggleFriend(friend: Profile) {
        withAnimation {
            if taggedFriends.contains(friend) {
                taggedFriends.remove(object: friend)
            } else {
                taggedFriends.append(friend)
            }
        }
    }
}
