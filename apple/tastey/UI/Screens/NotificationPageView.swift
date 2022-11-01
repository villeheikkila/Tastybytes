import SwiftUI

struct NotificationPageView: View {
    @EnvironmentObject var currentProfile: CurrentProfile

    var body: some View {
        ScrollView {
            Text("Notifications")
                .font(.headline)
            VStack {
                ForEach(currentProfile.notifications) {
                    notification in
                    HStack {
                        switch notification.content {
                        case let .message(message):
                            MessageNotificationView(message: message)
                        case let .friendRequest(friendRequest):
                            FriendRequestNotificationView(friend: friendRequest)
                        case let .taggedCheckIn(taggedCheckIn):
                            TaggedInCheckInNotificationView(checkIn: taggedCheckIn)
                        case let .checkInReaction(checkInReaction):
                            CheckInReactionNotificationView(checkInReaction: checkInReaction)
                        default:
                            EmptyView()
                        }
                        Spacer()
                        Button(action: {
                            currentProfile.deleteNotifications(notification: notification)
                        }) {
                            Image(systemName: "xmark.app")
                                .imageScale(.large)
                        }
                    }
                    .padding(.all, 12)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                    .padding([.leading, .trailing], 10)
                }
            }
        }.refreshable {
            currentProfile.refresh()
        }
    }
}

struct TaggedInCheckInNotificationView: View {
    let checkIn: CheckIn

    var body: some View {
        NavigationLink(value: checkIn) {
            HStack {
                AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 32, id: checkIn.profile.id)
                Text("\(checkIn.profile.getPreferredName()) tagged you in a check-in of \(checkIn.product.getDisplayName(.full))")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct FriendRequestNotificationView: View {
    let friend: Friend

    var body: some View {
        NavigationLink(value: Route.currentUserFriends) {
            HStack {
                AvatarView(avatarUrl: friend.sender.getAvatarURL(), size: 32, id: friend.sender.id)
                Text("\(friend.sender.getPreferredName()) sent you a friend request!")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct MessageNotificationView: View {
    let message: String

    var body: some View {
        Text(message)
    }
}

struct CheckInReactionNotificationView: View {
    let checkInReaction: CheckInReactionWithCheckIn

    var body: some View {
        NavigationLink(value: checkInReaction.checkIn) {
            HStack {
                AvatarView(avatarUrl: checkInReaction.profile.getAvatarURL(), size: 32, id: checkInReaction.profile.id)
                Text("\(checkInReaction.profile.getPreferredName()) reacted to your check-in of \(checkInReaction.checkIn.product.getDisplayName(.full))")
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
