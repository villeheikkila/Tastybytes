import Firebase
import FirebaseMessaging
import SwiftUI

@MainActor
final class NotificationManager: ObservableObject {
  private let logger = getLogger(category: "NotificationManager")
  @Published var pushNotificationSettings: ProfilePushNotification?
  @Published var unreadCount: Int = 0
  @Published private(set) var notifications = [Notification]() {
    didSet {
      withAnimation {
        self.filter = nil
        self.filteredNotifications = self.notifications
      }
    }
  }

  let repository: Repository
  let feedbackManager: FeedbackManager

  init(repository: Repository, feedbackManager: FeedbackManager) {
    self.repository = repository
    self.feedbackManager = feedbackManager
  }

  var isUpToDate: Bool {
    unreadCount == notifications
      .filter { $0.seenAt == nil }
      .count
  }

  @Published var filter: NotificationType? {
    didSet {
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
            case .checkInComment:
              return self.filter == .message
            case .taggedCheckIn:
              return self.filter == .taggedCheckIn
            }
          }
        }
      }
    }
  }

  @Published var filteredNotifications: [Notification] = []

  func getUnreadFriendRequestCount() -> Int {
    notifications
      .filter { notification in
        switch notification.content {
        case .friendRequest:
          return notification.seenAt == nil
        default:
          return false
        }
      }
      .count
  }

  func getUnreadCount() async {
    switch await repository.notification.getUnreadCount() {
    case let .success(count):
      withAnimation {
        self.unreadCount = count
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed: \(error.localizedDescription)")
    }
  }

  func refresh(reset: Bool = false, withFeedback: Bool = false) async {
    if reset, withFeedback {
      feedbackManager.trigger(.impact(intensity: .low))
    }
    switch await repository.notification.getAll(afterId: reset ? nil : notifications.first?.id) {
    case let .success(newNotifications):
      if reset {
        notifications = newNotifications
        if withFeedback {
          feedbackManager.trigger(.notification(.success))
        }
        unreadCount = newNotifications
          .filter { $0.seenAt == nil }
          .count
      } else {
        notifications.append(contentsOf: newNotifications)
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed: \(error.localizedDescription)")
    }
  }

  func deleteAll() async {
    switch await repository.notification.deleteAll() {
    case .success:
      withAnimation {
        self.notifications = [Notification]()
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed: \(error.localizedDescription)")
    }
  }

  func markAllAsRead() async {
    switch await repository.notification.markAllRead() {
    case .success:
      notifications = notifications.map { notification in
        if notification.seenAt != nil {
          return notification
        }
        return Notification(
          id: notification.id,
          createdAt: notification.createdAt,
          seenAt: Date(),
          content: notification.content
        )
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed: \(error.localizedDescription)")
    }
  }

  func markAllFriendRequestsAsRead() async {
    let containsFriendRequests = notifications.contains(where: { notification in
      switch notification.content {
      case .friendRequest:
        return true
      default:
        return false
      }
    })

    if containsFriendRequests {
      switch await repository.notification.markAllFriendRequestsAsRead() {
      case let .success(updatedNotifications):
        notifications = notifications.map { notification in
          if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
            return updatedNotification
          } else {
            return notification
          }
        }
      case let .failure(error):
        guard !error.localizedDescription.contains("cancelled") else { return }
        feedbackManager.toggle(.error(.unexpected))
        logger.error("failed: \(error.localizedDescription)")
      }
    }
  }

  func markCheckInAsRead(checkIn: CheckIn) async {
    let containsCheckIn = notifications.contains(where: { notification in
      switch notification.content {
      case let .checkInReaction(cir):
        return cir.checkIn == checkIn
      case let .taggedCheckIn(tci):
        return tci == checkIn
      case let .checkInComment(cic):
        return cic.checkIn == checkIn
      default:
        return false
      }
    })

    if containsCheckIn {
      switch await repository.notification.markAllCheckInNotificationsAsRead(checkInId: checkIn.id) {
      case let .success(updatedNotifications):
        notifications = notifications.map { notification in
          if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
            return updatedNotification
          } else {
            return notification
          }
        }
      case let .failure(error):
        guard !error.localizedDescription.contains("cancelled") else { return }
        feedbackManager.toggle(.error(.unexpected))
        logger.error("failed to mark check-in as read \(checkIn.id): \(error.localizedDescription)")
      }
    }
  }

  func markAsRead(_ notification: Notification) async {
    switch await repository.notification.markRead(id: notification.id) {
    case let .success(updatedNotification):
      notifications.replace(notification, with: updatedNotification)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to mark '\(notification.id)' as read: \(error.localizedDescription)")
    }
  }

  func deleteFromIndex(at: IndexSet) async {
    guard let index = at.first else { return }
    let notificationId = notifications[index].id
    switch await repository.notification.delete(id: notificationId) {
    case .success:
      withAnimation {
        _ = self.notifications.remove(at: index)
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete notification: \(error.localizedDescription)")
    }
  }

  func deleteNotifications(notification: Notification) async {
    switch await repository.notification.delete(id: notification.id) {
    case .success:
      withAnimation {
        self.notifications.remove(object: notification)
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete notification '\(notification.id)': \(error.localizedDescription)")
    }
  }

  func updatePushNotificationSettingsForDevice(sendReactionNotifications: Bool? = nil,
                                               sendTaggedCheckInNotifications: Bool? = nil,
                                               sendFriendRequestNotifications: Bool? = nil,
                                               sendCheckInCommentNotifications: Bool? = nil) async
  {
    guard let updateRequest = pushNotificationSettings?.copyWith(
      sendReactionNotifications: sendReactionNotifications,
      sendTaggedCheckInNotifications: sendTaggedCheckInNotifications,
      sendFriendRequestNotifications: sendFriendRequestNotifications,
      sendCheckInCommentNotifications: sendCheckInCommentNotifications
    ) else { return }
    switch await repository.notification.updatePushNotificationSettingsForDevice(updateRequest: updateRequest) {
    case let .success(pushNotificationSettings):
      print("Push \(pushNotificationSettings)")
      self.pushNotificationSettings = pushNotificationSettings
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update push notification settings for device: \(error.localizedDescription)")
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
          switch await self.repository.notification
            .refreshPushNotificationToken(token: Profile.PushNotificationToken(firebaseRegistrationToken: token))
          {
          case let .success(pushNotificationSettings):
            self.pushNotificationSettings = pushNotificationSettings
          case let .failure(error):
            logger.error("failed to save FCM token (\(String(describing: token))): \(error.localizedDescription)")
          }
        }
      }
    }
  }
}
