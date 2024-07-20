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
    public var task: Task<Void, Never>?

    public var pushNotificationSettings: Profile.PushNotification?
    public var unreadCount: Int = 0
    public var alertError: AlertEvent?
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
        do {
            let count = try await repository.notification.getUnreadCount()
            withAnimation {
                self.unreadCount = count
            }
        } catch {
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
            do {
                let newNotifications = try await repository.notification.getAll(afterId: reset ? nil : notifications.first?.id)
                if reset {
                    notifications = newNotifications
                    unreadCount = newNotifications
                        .filter { $0.seenAt == nil }
                        .count
                } else {
                    notifications.insert(contentsOf: newNotifications, at: 0)
                }
                self.state = .populated
            } catch {
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
        do {
            try await repository.notification.deleteAll()
            withAnimation {
                self.notifications = [Models.Notification]()
                self.unreadCount = 0
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete all notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllAsRead() async {
        do {
            let readNotifications = try await repository.notification.markAllRead()
            let markedAsSeenNotifications = notifications.map { notification in
                let readNotification = readNotifications.first(where: { rn in rn.id == notification.id })
                return readNotification ?? notification
            }

            withAnimation {
                notifications = markedAsSeenNotifications
                self.unreadCount = 0
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllFriendRequestsAsRead() async {
        let containsFriendRequests = notifications.contains(where: \.isFriendRequest)

        if containsFriendRequests {
            do {
                let updatedNotifications = try await repository.notification.markAllFriendRequestsAsRead()
                notifications = notifications.map { notification in
                    if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                        updatedNotification
                    } else {
                        notification
                    }
                }
            } catch {
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
            do {
                let updatedNotifications = try await repository.notification.markAllCheckInNotificationsAsRead(checkInId: checkIn.id)
                notifications = notifications.map { notification in
                    if let updatedNotification = updatedNotifications.first(where: { $0.id == notification.id }) {
                        updatedNotification
                    } else {
                        notification
                    }
                }
                unreadCount = notifications.count
            } catch {
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to mark check-in as read \(checkIn.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    public func markAsRead(_ notification: Models.Notification) async {
        do {
            let updatedNotification = try await repository.notification.markRead(id: notification.id)
            notifications.replace(notification, with: updatedNotification)
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark '\(notification.id)' as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteFromIndex(at: IndexSet) async {
        guard let index = at.first, let notification = notifications[safe: index] else { return }
        do {
            try await repository.notification.delete(id: notification.id)
            withAnimation {
                self.notifications = notifications.removing(notification)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteNotification(notification: Models.Notification) async {
        do {
            try await repository.notification.delete(id: notification.id)
            withAnimation {
                self.notifications = notifications.removing(notification)
            }
        } catch {
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
        do {
            let pushNotificationSettings = try await repository.notification.updatePushNotificationSettingsForDevice(updateRequest: updateRequest)
            self.pushNotificationSettings = pushNotificationSettings
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update push notification settings for device. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refreshDeviceToken(deviceToken: String) async {
        do {
            let pushNotificationSettings = try await repository.notification.refreshPushNotificationToken(deviceToken: deviceToken)
            logger.notice("Device token refreshed: \(deviceToken)")
            self.pushNotificationSettings = pushNotificationSettings
        } catch {
            logger.error("Failed to save device token (\(String(describing: deviceToken))). Error: \(error) (\(#file):\(#line))")
        }
    }
}
