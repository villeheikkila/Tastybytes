import SwiftUI
import FirebaseMessaging

final class NotificationManager: NSObject, ObservableObject {
    @Published private(set) var notifications = [Notification]()

    func getAll() {
        Task {
            switch await repository.notification.getAll() {
            case let .success(notifications):
                await MainActor.run {
                    self.notifications = notifications
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAll() {
        DispatchQueue.main.async {
            self.notifications = [Notification]()
        }
    }
    
    func markAllAsRead() {
        DispatchQueue.main.async {
            self.notifications = self.notifications.map {
                n in
                if n.seenAt == nil {
                    return Notification(id: n.id, createdAt: n.createdAt, seenAt: Date(), content: n.content)
                } else {
                    return n
                }
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
                switch await repository.notification.markAllFriendRequestsAsRead() {
                case let .success(updatedNotifications):
                    await MainActor.run {
                        self.notifications = self.notifications.map {
                            n in
                            if let updatedNotification = updatedNotifications.first(where: { $0.id == n.id }) {
                                return updatedNotification
                            } else {
                                return n
                            }
                        }
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func markCheckInAsRead(checkIn: CheckIn) {
        let containsCheckIn = notifications.contains(where: {
            switch $0.content {
            case let .checkInReaction(cr):
                return cr.checkIn == checkIn
            case let .taggedCheckIn(tc):
                return tc == checkIn
            default:
                return false
            }
        })

        if containsCheckIn {
            Task {
                switch await repository.notification.markAllCheckInNotificationsAsRead(checkInId: checkIn.id) {
                case let .success(updatedNotifications):
                    await MainActor.run {
                        self.notifications = self.notifications.map {
                            n in
                            if let updatedNotification = updatedNotifications.first(where: { $0.id == n.id }) {
                                return updatedNotification
                            } else {
                                return n
                            }
                        }
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func markAsRead(_ notifaction: Notification) {
        Task {
            switch await repository.notification.markRead(id: notifaction.id) {
            case let .success(updatedNotification):
                await MainActor.run {
                    if let index = self.notifications.firstIndex(of: notifaction) {
                        self.notifications[index] = updatedNotification
                    }
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    func deleteFromIndex(at: IndexSet) {
        if let index = at.first {
            Task {
                switch await repository.notification.delete(id: notifications[index].id) {
                case .success(_):
                    await MainActor.run {
                        DispatchQueue.main.async {
                            self.notifications.remove(at: index)
                        }
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func deleteNotifications(notification: Notification) {
        Task {
            switch await repository.notification.delete(id: notification.id) {
            case .success():
                await MainActor.run {
                    self.notifications.removeAll(where: { $0.id == notification.id })
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        self.getAll()
        return [[.sound]]
    }

    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
    }

}
