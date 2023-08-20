import Firebase
import FirebaseMessaging
import Model
import Observation
import OSLog
import SwiftUI

@Observable
final class NotificationManager {
    private let logger = Logger(category: "NotificationManager")
    private(set) var notifications = [Model.Notification]()

    var pushNotificationSettings: ProfilePushNotification? = nil
    var unreadCount: Int = 0

    private let repository: Repository
    private let feedbackManager: FeedbackManager

    init(repository: Repository, feedbackManager: FeedbackManager) {
        self.repository = repository
        self.feedbackManager = feedbackManager
    }

    func getUnreadFriendRequestCount() -> Int {
        notifications
            .filter { notification in
                switch notification.content {
                case .friendRequest where notification.seenAt == nil:
                    true
                default:
                    false
                }
            }
            .count
    }

    func getUnreadCount() async {
        switch await repository.notification.getUnreadCount() {
        case let .success(count):
            await MainActor.run {
                withAnimation {
                    self.unreadCount = count
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to get all unread notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refresh(reset: Bool = false, withFeedback: Bool = false) async {
        if reset, withFeedback {
            feedbackManager.trigger(.impact(intensity: .low))
        }
        switch await repository.notification.getAll(afterId: reset ? nil : notifications.first?.id) {
        case let .success(newNotifications):
            await MainActor.run {
                if reset {
                    notifications = newNotifications
                    unreadCount = newNotifications
                        .filter { $0.seenAt == nil }
                        .count

                    if withFeedback {
                        feedbackManager.trigger(.notification(.success))
                    }
                } else {
                    notifications.append(contentsOf: newNotifications)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to refresh notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteAll() async {
        switch await repository.notification.deleteAll() {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.notifications = [Model.Notification]()
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete all notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    func markAllAsRead() async {
        switch await repository.notification.markAllRead() {
        case .success:
            let markedAsSeenNotifications = notifications.map { notification in
                notification.seenAt == nil ? notification.copyWith(seenAt: Date()) : notification
            }

            await MainActor.run {
                withAnimation {
                    notifications = markedAsSeenNotifications
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    func markAllFriendRequestsAsRead() async {
        let containsFriendRequests = notifications.contains(where: { $0.isFriendRequest })

        if containsFriendRequests {
            switch await repository.notification.markAllFriendRequestsAsRead() {
            case let .success(updatedNotifications):
                notifications = notifications.map { notification in
                    if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                        updatedNotification
                    } else {
                        notification
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                feedbackManager.toggle(.error(.unexpected))
                logger.error("Failed to mark all friend requests as read. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func markCheckInAsRead(checkIn: CheckIn) async {
        let containsCheckIn = notifications.contains(where: { notification in
            switch notification.content {
            case let .checkInReaction(cir):
                cir.checkIn == checkIn
            case let .taggedCheckIn(tci):
                tci == checkIn
            case let .checkInComment(cic):
                cic.checkIn == checkIn
            default:
                false
            }
        })

        if containsCheckIn {
            switch await repository.notification.markAllCheckInNotificationsAsRead(checkInId: checkIn.id) {
            case let .success(updatedNotifications):
                notifications = notifications.map { notification in
                    if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                        updatedNotification
                    } else {
                        notification
                    }
                }
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                feedbackManager.toggle(.error(.unexpected))
                logger.error("Failed to mark check-in as read \(checkIn.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func markAsRead(_ notification: Model.Notification) async {
        switch await repository.notification.markRead(id: notification.id) {
        case let .success(updatedNotification):
            notifications.replace(notification, with: updatedNotification)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to mark '\(notification.id)' as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteFromIndex(at: IndexSet) async {
        guard let index = at.first else { return }
        let notificationId = notifications[index].id
        switch await repository.notification.delete(id: notificationId) {
        case .success:
            await MainActor.run {
                withAnimation {
                    _ = self.notifications.remove(at: index)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteNotifications(notification: Model.Notification) async {
        switch await repository.notification.delete(id: notification.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.notifications.remove(object: notification)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete notification '\(notification.id)'. Error: \(error) (\(#file):\(#line))")
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
            self.pushNotificationSettings = pushNotificationSettings
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to update push notification settings for device. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refreshAPNS() {
        Messaging.messaging().token { token, error in
            if let error {
                let logger = Logger(category: "Messaging")
                logger.error("Failed to fetch FCM registration token. Error: \(error) (\(#file):\(#line))")
            } else if let token {
                Task {
                    let logger = Logger(category: "PushNotificationToken")
                    switch await self.repository.notification
                        .refreshPushNotificationToken(token: Profile
                            .PushNotificationToken(firebaseRegistrationToken: token))
                    {
                    case let .success(pushNotificationSettings):
                        self.pushNotificationSettings = pushNotificationSettings
                    case let .failure(error):
                        logger
                            .error(
                                "Failed to save FCM token (\(String(describing: token))). Error: \(error) (\(#file):\(#line))"
                            )
                    }
                }
            }
        }
    }
}
