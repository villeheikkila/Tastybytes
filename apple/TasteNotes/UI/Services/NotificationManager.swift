import SwiftUI

final class NotificationManager: ObservableObject {
    @Published private(set) var notifaction: [Notification] = []
    @Published var notifications = [Notification]()
        
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
    
    func markAllFriendRequestsAsRead() {
        Task {
            switch await repository.notification.markAllFriendRequestsAsRead() {
            case .success(_):
                await MainActor.run {
                    self.notifications = self.notifications.filter {
                        switch $0.content {
                        case .friendRequest(_):
                            return false
                        default:
                            return true
                        }
                    }
                }
            case let .failure(error):
                print(error.localizedDescription)
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
            print(at.first)
            DispatchQueue.main.async {
                self.notifications.remove(at: index)
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
