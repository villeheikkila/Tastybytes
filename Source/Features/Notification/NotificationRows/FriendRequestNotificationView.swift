import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendRequestNotificationView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let friend: Friend
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(open: .screen(.currentUserFriends), asTapGesture: true) {
            NotificationFromUserWrapper(profile: friend.sender, createdAt: createdAt) {
                Text("notifications.friendRequest.recievedFrom \(friend.sender.preferredName)")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
