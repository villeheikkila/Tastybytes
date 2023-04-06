import SwiftUI

struct NotificationTab: View {
  let client: Client
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var hapticManager: HapticManager
  @StateObject private var router = Router()
  @Binding private var resetNavigationOnTab: Tab?

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        ForEach(notificationManager.filteredNotifications) { notification in
          HStack {
            switch notification.content {
            case let .message(message):
              MessageNotificationView(message: message)
                .accessibilityAddTraits(.isButton)
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
          }.if(notification.seenAt != nil, transform: { view in
            view.listRowBackground(Color.clear)
          })
        }
        .onDelete(perform: { index in
          notificationManager.deleteFromIndex(at: index)
        })
      }
      .refreshable {
        await hapticManager.wrapWithHaptics {
          await notificationManager.refresh(reset: true)
        }
      }
      .navigationTitle(notificationManager.filter?.label ?? "Notifications")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        toolbarContent
      }
      .onOpenURL { url in
        if let detailPage = url.detailPage {
          router.fetchAndNavigateTo(client, detailPage, resetStack: true)
        }
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
      .withRoutes(client)
      .withSheets(client, sheetRoute: $router.sheet)
    }
    .environmentObject(router)
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup {
      Menu {
        Button(action: {
          hapticManager.trigger(.impact(intensity: .low))
          notificationManager.markAllAsRead()
        }, label: {
          Label("Mark all read", systemImage: "envelope.open")
        })
        Button(action: {
          hapticManager.trigger(.impact(intensity: .low))
          notificationManager.deleteAll()
        }, label: {
          Label("Delete all", systemImage: "trash")
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
