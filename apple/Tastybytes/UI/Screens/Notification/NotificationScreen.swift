import SwiftUI

struct NotificationScreen: View {
  @EnvironmentObject private var notificationManager: NotificationManager

  var body: some View {
    List {
      ForEach(notificationManager.filteredNotifications) { notification in
        HStack {
          switch notification.content {
          case let .message(message):
            MessageNotificationView(message: message)
              .accessibilityAddTraits(.isButton)
              .onTapGesture {
                Task { await notificationManager.markAsRead(notification) }
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
        .if(notification.seenAt != nil, transform: { view in
          view.listRowBackground(Color.clear)
        })
      }
      .onDelete(perform: { index in Task {
        await notificationManager.deleteFromIndex(at: index)
      } })
    }
    .refreshable {
      await notificationManager.refresh(reset: true)
    }
    .navigationTitle(notificationManager.filter?.label ?? "Notifications")
    .navigationBarTitleDisplayMode(.inline)
  }
}
