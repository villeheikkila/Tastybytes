import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class NotificationEnvironmentModel {
    private let logger = Logger(category: "NotificationEnvironmentModel")
    public var notifications = [Models.Notification]()
    public var isRefreshing = false
    public var isInitialized = false
    public var task: Task<Void, Never>?

    public var pushNotificationSettings: ProfilePushNotification?
    public var unreadCount: Int = 0
    public var alertError: AlertError?
    public var state: ScreenState = .loading

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public var unreadFriendRequestCount: Int {
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
            withAnimation {
                self.unreadCount = count
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to get all unread notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refresh(reset: Bool = false, withHaptics: Bool = false) {
        guard task == nil else {
            logger.info("Tried to refresh but already fetching notifications. Skipping.")
            return
        }
        task = Task {
            defer { task = nil }
            if withHaptics {
                isRefreshing = true
            }
            switch await repository.notification.getAll(afterId: reset ? nil : notifications.first?.id) {
            case let .success(newNotifications):
                isInitialized = true
                if reset {
                    notifications = newNotifications
                    unreadCount = newNotifications
                        .filter { $0.seenAt == nil }
                        .count
                } else {
                    notifications.append(contentsOf: newNotifications)
                }
                self.state = .populated
            case let .failure(error):
                guard !error.isCancelled else { return }
                if state != .populated {
                    self.state = .error([error])
                }
                logger.error("Failed to refresh notifications. Error: \(error) (\(#file):\(#line))")
            }
            if withHaptics {
                isRefreshing = false
            }
        }
    }

    public func deleteAll() async {
        switch await repository.notification.deleteAll() {
        case .success:
            withAnimation {
                self.notifications = [Models.Notification]()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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

            withAnimation {
                notifications = markedAsSeenNotifications
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllFriendRequestsAsRead() async {
        let containsFriendRequests = notifications.contains(where: \.isFriendRequest)

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
                guard !error.isCancelled else { return }
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
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to mark check-in as read \(checkIn.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    public func markAsRead(_ notification: Models.Notification) async {
        switch await repository.notification.markRead(id: notification.id) {
        case let .success(updatedNotification):
            notifications.replace(notification, with: updatedNotification)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark '\(notification.id)' as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteFromIndex(at: IndexSet) async {
        guard let index = at.first else { return }
        let notificationId = notifications[index].id
        switch await repository.notification.delete(id: notificationId) {
        case .success:
            withAnimation {
                _ = self.notifications.remove(at: index)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteNotifications(notification: Models.Notification) async {
        switch await repository.notification.delete(id: notification.id) {
        case .success:
            withAnimation {
                self.notifications.remove(object: notification)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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
            guard !error.isCancelled else { return }
            alertError = .init()
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
