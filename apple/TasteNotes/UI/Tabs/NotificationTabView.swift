import SwiftUI

struct NotificationTabView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var routeManager: RouteManager

  var body: some View {
    NavigationStack(path: $routeManager.path) {
      WithRoutes {
        List {
          ForEach(notificationManager.notifications) {
            notification in
            HStack {
              switch notification.content {
              case let .message(message):
                MessageNotificationView(message: message)
                  .onTapGesture {
                    notificationManager.markAsRead(notification)
                  }
              case let .friendRequest(friendRequest):
                FriendRequestNotificationView(friend: friendRequest)
              case let .taggedCheckIn(taggedCheckIn):
                TaggedInCheckInNotificationView(checkIn: taggedCheckIn)
              case let .checkInReaction(checkInReaction):
                CheckInReactionNotificationView(checkInReaction: checkInReaction)
              }
              Spacer()
            }
          }
          .onDelete(perform: notificationManager.deleteFromIndex)
        }
        .refreshable {
          notificationManager.refresh(reset: true)
        }
        .navigationTitle("Notifications")
        .toolbar {
          toolbarContent
        }
      }
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        Button(action: {
          notificationManager.deleteAll()
        }) {
          Label("Delete all notifications", systemImage: "trash")
        }
      } label: {
        Text("Mark all read")
      } primaryAction: {
        notificationManager.markAllAsRead()
      }
    }
  }
}

struct TaggedInCheckInNotificationView: View {
  let checkIn: CheckIn

  var body: some View {
    NavigationLink(value: checkIn) {
      HStack {
        AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 32, id: checkIn.profile.id)
        Text("\(checkIn.profile.preferredName) tagged you in a check-in of \(checkIn.product.getDisplayName(.full))")
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
        Text("\(friend.sender.preferredName) sent you a friend request!")
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
  let checkInReaction: CheckInReaction.JoinedCheckIn

  var body: some View {
    NavigationLink(value: checkInReaction.checkIn) {
      HStack {
        AvatarView(avatarUrl: checkInReaction.profile.getAvatarURL(), size: 32, id: checkInReaction.profile.id)
        Text(
          """
          \(checkInReaction.profile.preferredName)\
           reacted to your check-in of\
           \(checkInReaction.checkIn.product.getDisplayName(.full))
          """
        )

        Spacer()
      }
    }
    .buttonStyle(.plain)
  }
}
