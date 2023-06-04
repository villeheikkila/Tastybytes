import SwiftUI

struct NotificationScreen: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager

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
          case let .checkInComment(checkInComment):
            CheckInCommentNotificationView(checkInComment: checkInComment)
          case let .checkInReaction(checkInReaction):
            CheckInReactionNotificationView(checkInReaction: checkInReaction)
          }
          Spacer()
        }
        .listRowSeparator(.hidden)
        .if(notification.seenAt != nil, transform: { view in
          view.listRowBackground(Color(.systemGray5))
        })
      }
      .onDelete(perform: { index in Task {
        await notificationManager.deleteFromIndex(at: index)
      } })
    }
    .task {
      await notificationManager.refresh(reset: true)
    }
    #if !targetEnvironment(macCatalyst)
    .refreshable {
      await notificationManager.refresh(reset: true, withFeedback: true)
    }
    #endif
    .navigationTitle(notificationManager.filter?.label ?? "Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup {
      Menu {
        ProgressButton("Mark all read", systemImage: "envelope.open", action: {
          feedbackManager.trigger(.impact(intensity: .low))
          await notificationManager.markAllAsRead()
        })
        ProgressButton("Delete all", systemImage: "trash", action: {
          feedbackManager.trigger(.impact(intensity: .low))
          await notificationManager.deleteAll()
        })
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    }
    ToolbarTitleMenu {
      Button {
        notificationManager.filter = nil
      } label: {
        Label("Show All", systemImage: "bell.fill")
      }
      Divider()
      ForEach(NotificationType.allCases) { type in
        Button {
          notificationManager.filter = type
        } label: {
          Label(type.label, systemImage: type.systemImage)
        }
      }
    }
  }
}
