import FirebaseMessaging
import SwiftUI

final class NotificationManager: ObservableObject {
  private let logger = getLogger(category: "NotificationManager")
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  @Published private(set) var notifications = [Notification]() {
    didSet {
      DispatchQueue.main.async {
        withAnimation {
          self.filter = nil
          self.filteredNotifications = self.notifications
        }
      }
    }
  }

  @Published var filter: NotificationType? {
    didSet {
      DispatchQueue.main.async {
        withAnimation {
          self.filteredNotifications = self.notifications.filter { notification in
            if self.filter == nil {
              return true
            } else {
              switch notification.content {
              case .checkInReaction:
                return self.filter == .checkInReaction
              case .friendRequest:
                return self.filter == .friendRequest
              case .message:
                return self.filter == .message
              case .taggedCheckIn:
                return self.filter == .taggedCheckIn
              }
            }
          }
        }
      }
    }
  }

  @Published var filteredNotifications: [Notification] = []

  func getUnreadCount() -> Int {
    notifications
      .filter { $0.seenAt == nil }
      .count
  }

  func refresh(reset: Bool = false) {
    Task {
      switch await client.notification.getAll(afterId: reset ? nil : notifications.first?.id) {
      case let .success(newNotifications):
        await MainActor.run {
          if reset {
            self.notifications = newNotifications
          } else {
            self.notifications.append(contentsOf: newNotifications)
          }
        }
      case let .failure(error):
        logger.error("failed: \(error.localizedDescription)")
      }
    }
  }

  func deleteAll() {
    Task {
      switch await client.notification.deleteAll() {
      case .success:
        await MainActor.run {
          withAnimation {
            self.notifications = [Notification]()
          }
        }
      case let .failure(error):
        logger.error("failed: \(error.localizedDescription)")
      }
    }
  }

  func markAllAsRead() {
    Task {
      switch await client.notification.markAllRead() {
      case .success:
        await MainActor.run {
          self.notifications = self.notifications.map {
            if $0.seenAt == nil {
              return Notification(id: $0.id, createdAt: $0.createdAt, seenAt: Date(), content: $0.content)
            } else {
              return $0
            }
          }
        }
      case let .failure(error):
        logger.error("failed: \(error.localizedDescription)")
      }
    }
  }

  func markAllFriendRequestsAsRead() {
    let containsFriendRequests = notifications.contains(where: {
      switch $0.content {
      case .friendRequest:
        return true
      default:
        return false
      }
    })

    if containsFriendRequests {
      Task {
        switch await client.notification.markAllFriendRequestsAsRead() {
        case let .success(updatedNotifications):
          await MainActor.run {
            self.notifications = self.notifications.map {
              notification in
              if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                return updatedNotification
              } else {
                return notification
              }
            }
          }
        case let .failure(error):
          logger.error("failed: \(error.localizedDescription)")
        }
      }
    }
  }

  func markCheckInAsRead(checkIn: CheckIn) {
    let containsCheckIn = notifications.contains(where: {
      switch $0.content {
      case let .checkInReaction(cir):
        return cir.checkIn == checkIn
      case let .taggedCheckIn(tci):
        return tci == checkIn
      default:
        return false
      }
    })

    if containsCheckIn {
      Task {
        switch await client.notification.markAllCheckInNotificationsAsRead(checkInId: checkIn.id) {
        case let .success(updatedNotifications):
          await MainActor.run {
            self.notifications = self.notifications.map {
              notification in
              if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                return updatedNotification
              } else {
                return notification
              }
            }
          }
        case let .failure(error):
          logger.error("failed to mark check-in as read \(checkIn.id): \(error.localizedDescription)")
        }
      }
    }
  }

  func markAsRead(_ notification: Notification) {
    Task {
      switch await client.notification.markRead(id: notification.id) {
      case let .success(updatedNotification):
        await MainActor.run {
          if let index = self.notifications.firstIndex(of: notification) {
            self.notifications[index] = updatedNotification
          }
        }
      case let .failure(error):
        logger.error("failed to mark '\(notification.id)' as read: \(error.localizedDescription)")
      }
    }
  }

  func deleteFromIndex(at: IndexSet) {
    if let index = at.first {
      Task {
        switch await client.notification.delete(id: notifications[index].id) {
        case .success:
          await MainActor.run {
            withAnimation {
              _ = self.notifications.remove(at: index)
            }
          }
        case let .failure(error):
          logger
            .error("failed to delete notification '\(self.notifications[index].id)': \(error.localizedDescription)")
        }
      }
    }
  }

  func deleteNotifications(notification: Notification) {
    Task {
      switch await client.notification.delete(id: notification.id) {
      case .success:
        await MainActor.run {
          withAnimation {
            self.notifications.remove(object: notification)
          }
        }
      case let .failure(error):
        logger.error("failed to delete notification '\(notification.id)': \(error.localizedDescription)")
      }
    }
  }

  func refreshAPNS() {
    Messaging.messaging().token { token, error in
      if let error {
        let logger = getLogger(category: "Messaging")
        logger.error("failed to fetch FCM registration token: \(error.localizedDescription)")
      } else if let token {
        Task {
          let logger = getLogger(category: "PushNotificationToken")
          switch await self.client.profile
            .uploadPushNotificationToken(token: Profile.PushNotificationToken(firebaseRegistrationToken: token))
          {
          case .success:
            break
          case let .failure(error):
            logger
              .error("failed to save FCM token (\(String(describing: token))): \(error.localizedDescription)")
          }
        }
      }
    }
  }
}

// extension NotificationManager: UNUserNotificationCenterDelegate {
//  @MainActor
//  func userNotificationCenter(_: UNUserNotificationCenter,
//                              willPresent notification: UNNotification) async
//    -> UNNotificationPresentationOptions
//  {
//    _ = notification.request.content.userInfo
//    refresh()
//    return [[.sound]]
//  }
//
//  @MainActor
//  func userNotificationCenter(_: UNUserNotificationCenter,
//                              didReceive response: UNNotificationResponse) async
//  {
//    _ = response.notification.request.content.userInfo
//  }
// }
