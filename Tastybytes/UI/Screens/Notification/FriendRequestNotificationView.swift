import Models
import SwiftUI

struct FriendRequestNotificationView: View {
    let friend: Friend

    var body: some View {
        RouterLink(screen: .currentUserFriends) {
            HStack {
                AvatarView(avatarUrl: friend.sender.avatarUrl, size: 32, id: friend.sender.id)
                Text("\(friend.sender.preferredName) sent you a friend request!")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
