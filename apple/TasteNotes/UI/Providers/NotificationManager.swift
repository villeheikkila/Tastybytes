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
    
    func deleteFromIndex(at: IndexSet) {
        if let index = at.first {
            print(notifaction[index])
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
