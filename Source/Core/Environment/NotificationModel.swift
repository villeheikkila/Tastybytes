import Extensions
import Models
import Logging
import Repositories
import SwiftUI

@MainActor
@Observable
public final class NotificationModel {
    private let logger = Logger(label: "NotificationModel")
    public var notifications = [Models.Notification.Joined]()
    public var isRefreshing = false
    public var task: Task<Void, Never>?

    public var pushNotificationSettings: Profile.PushNotificationSettings?
    public var unreadCount: Int = 0
    public var alertError: AlertEvent?
    public var state: ScreenState = .loading

    private let repository: Repository
    private let profileId: Profile.Id

    public init(repository: Repository, profileId: Profile.Id) {
        self.repository = repository
        self.profileId = profileId
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
            let count = try await repository.notification.getUnreadCount(profileId: profileId)
            unreadCount = count
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
                let newNotifications = try await repository.notification.getAll(profileId: profileId, afterId: reset ? nil : notifications.first?.id)
                if reset {
                    notifications = newNotifications
                    unreadCount = newNotifications.count { $0.seenAt == nil }
                } else {
                    notifications.insert(contentsOf: newNotifications, at: 0)
                }
                self.state = .populated
            } catch {
                guard !error.isCancelled else { return }
                if state != .populated {
                    self.state = .error(error)
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
            try await repository.notification.deleteAll(profileId: profileId)
            notifications = [Models.Notification.Joined]()
            unreadCount = 0
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

            notifications = markedAsSeenNotifications
            unreadCount = 0
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAllFriendRequestsAsRead() async {
        guard notifications.contains(where: \.isFriendRequest) else { return }
        do {
            let updatedNotifications = try await repository.notification.markAllFriendRequestsAsRead()
            notifications = notifications.map { notification in
                updatedNotifications.first { $0.id == notification.id } ?? notification
            }
            unreadCount = notifications.count {
                $0.seenAt == nil
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to mark all friend requests as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markCheckInAsRead(id: CheckIn.Id) async {
        let containsCheckIn = notifications.contains {
            if case let .checkInReaction(cir) = $0.content { return cir.checkIn.id == id }
            if case let .taggedCheckIn(tci) = $0.content { return tci.id == id }
            if case let .checkInComment(cic) = $0.content { return cic.checkIn.id == id }
            return false
        }
        guard containsCheckIn else { return }
        do {
            let updatedNotifications = try await repository.notification.markAllCheckInNotificationsAsRead(checkInId: id)
            notifications = notifications.map { notification in
                updatedNotifications.first { $0.id == notification.id } ?? notification
            }
            unreadCount = notifications.count {
                $0.seenAt == nil
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to mark check-in as read \(id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func markAsRead(_ notification: Models.Notification.Joined) async {
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
            notifications = notifications.removing(notification)
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }
}
