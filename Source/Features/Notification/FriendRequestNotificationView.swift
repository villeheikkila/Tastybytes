import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendRequestNotificationView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let friend: Friend

    var body: some View {
        RouterLink(screen: .currentUserFriends) {
            HStack {
                Avatar(profile: friend.sender, size: 32)
                Text("notifications.friendRequest.recievedFrom \(friend.sender.preferredName)")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
