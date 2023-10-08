import Models
import Observation
import OSLog
import Repositories
import SwiftUI

@Observable
public final class NotificationEnvironmentModel {
    private let logger = Logger(category: "NotificationEnvironmentModel")
    public var notifications = [Models.Notification]()

    public var pushNotificationSettings: ProfilePushNotification? = nil
    public var unreadCount: Int = 0

    private let repository: Repository
    private let feedbackEnvironmentModel: FeedbackEnvironmentModel

    public init(repository: Repository, feedbackEnvironmentModel: FeedbackEnvironmentModel) {
        self.repository = repository
        self.feedbackEnvironmentModel = feedbackEnvironmentModel
    }

    public func getUnreadFriendRequestCount() -> Int {
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

    public func getUnreadCount() async {
        switch await repository.notification.getUnreadCount() {
        case let .success(count):
            await MainActor.run {
                withAnimation {
                    self.unreadCount = count
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to get all unread notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refresh(reset: Bool = false, withFeedback: Bool = false) async {
        if reset, withFeedback {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
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
                        feedbackEnvironmentModel.trigger(.notification(.success))
                    }
                } else {
                    notifications.append(contentsOf: newNotifications)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to refresh notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteAll() async {
        switch await repository.notification.deleteAll() {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.notifications = [Models.Notification]()
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete all notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllAsRead() async {
        switch await repository.notification.markAllRead() {
        case let .success(readNotifications):
            let markedAsSeenNotifications = notifications.map { notification in
                let readNotification = readNotifications.first(where: { rn in rn.id == notification.id })
                return readNotification ?? notification
            }

            await MainActor.run {
                withAnimation {
                    notifications = markedAsSeenNotifications
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllFriendRequestsAsRead() async {
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
                feedbackEnvironmentModel.toggle(.error(.unexpected))
                logger.error("Failed to mark all friend requests as read. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    public func markCheckInAsRead(checkIn: CheckIn) async {
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
                feedbackEnvironmentModel.toggle(.error(.unexpected))
                logger.error("Failed to mark check-in as read \(checkIn.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    public func markAsRead(_ notification: Models.Notification) async {
        switch await repository.notification.markRead(id: notification.id) {
        case let .success(updatedNotification):
            notifications.replace(notification, with: updatedNotification)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to mark '\(notification.id)' as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteFromIndex(at: IndexSet) async {
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteNotifications(notification: Models.Notification) async {
        switch await repository.notification.delete(id: notification.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.notifications.remove(object: notification)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to delete notification '\(notification.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updatePushNotificationSettingsForDevice(sendReactionNotifications: Bool? = nil,
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to update push notification settings for device. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refreshDeviceToken(deviceToken: String) async {
        switch await repository.notification
            .refreshPushNotificationToken(deviceToken: deviceToken)
        {
        case let .success(pushNotificationSettings):
            logger.notice("Device token refreshed: \(deviceToken)")
            self.pushNotificationSettings = pushNotificationSettings
        case let .failure(error):
            logger
                .error(
                    "Failed to save device token (\(String(describing: deviceToken))). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
