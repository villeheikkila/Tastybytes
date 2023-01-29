import SwiftUI

struct NotificationTabView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @StateObject private var router = Router()
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        ForEach(notificationManager.filteredNotifications) {
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
      .navigationTitle(notificationManager.filter?.label ?? "Notifications")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        toolbarContent
      }
      .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
        if tab == .notifications {
          if router.path.isEmpty {
            notificationManager.filter = nil
          } else {
            router.reset()
          }
          resetNavigationOnTab = nil
        }
      }
      .withRoutes()
    }
    .environmentObject(router)
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup {
      Menu {
        Button(action: {
          notificationManager.markAllAsRead()
        }) {
          Label("Mark all read", systemImage: "envelope.open")
        }
        Button(action: {
          notificationManager.deleteAll()
        }) {
          Label("Delete all", systemImage: "trash")
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    }
    ToolbarTitleMenu {
      Button {
        notificationManager.filter = nil
      } label: {
        Label("Show All", systemImage: "bell.fill")
      }
      Divider()
      ForEach(NotificationType.allCases, id: \.self) { type in
        Button {
          notificationManager.filter = type
        } label: {
          Label(type.label, systemImage: type.systemImage)
        }
      }
    }
  }
}

struct TaggedInCheckInNotificationView: View {
  let checkIn: CheckIn

  var body: some View {
    NavigationLink(value: Route.checkIn(checkIn)) {
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
    NavigationLink(value: Route.checkIn(checkInReaction.checkIn)) {
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
