import SwiftUI

struct NotificationTab: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      NotificationScreen()
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
