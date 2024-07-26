import Components

import Models
import SwiftUI

struct FriendRequestNotificationView: View {
    let friend: Friend.Saved
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(open: .screen(.currentUserFriends)) {
            NotificationFromUserWrapper(profile: friend.sender, createdAt: createdAt) {
                Text("notifications.friendRequest.recievedFrom \(friend.sender.preferredName)")
                Spacer()
            }
        }
    }
}
