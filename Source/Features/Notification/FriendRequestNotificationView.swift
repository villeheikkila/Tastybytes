import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct FriendRequestNotificationView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let friend: Friend

    var body: some View {
        RouterLink(screen: .currentUserFriends) {
            HStack {
                Avatar(profile: friend.sender)
                    .avatarSize(.large)
                Text("notifications.friendRequest.recievedFrom \(friend.sender.preferredName)")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
