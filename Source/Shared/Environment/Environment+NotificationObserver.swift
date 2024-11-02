import SwiftUI

struct NotificationObserverModifier: ViewModifier {
    let notificationName: Notification.Name
    let action: (Notification) -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: notificationName)
            ) { notification in
                action(notification)
            }
    }
}

extension View {
    func onNotification(
        named name: Notification.Name,
        perform action: @escaping (Notification) -> Void
    ) -> some View {
        modifier(NotificationObserverModifier(notificationName: name, action: action))
    }
}
