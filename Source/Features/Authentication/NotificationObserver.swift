
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct NotificationObserver<Content: View>: View {
    private let logger = Logger(category: "MainContent")
    @Environment(NotificationModel.self) private var notificationModel
    @Environment(\.scenePhase) private var phase

    @ViewBuilder let content: () -> Content

    private let publisher = NotificationCenter.default
        .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived"))

    var body: some View {
        content()
            .onChange(of: phase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await notificationModel.getUnreadCount()
                    }
                }
            }
            .onReceive(publisher) { notification in
                guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                      let unreadCount = aps["badge"] as? Int else { return }
                notificationModel.unreadCount = unreadCount
            }
            .task {
                if let deviceTokenForPusNotifications = await DeviceTokenActor.shared.deviceTokenForPusNotifications {
                    await notificationModel.refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
                }
            }
            .onAppear {
                notificationModel.refresh()
            }
    }
}

actor DeviceTokenActor {
    static let shared = DeviceTokenActor()

    var deviceTokenForPusNotifications: String?

    private init() {}

    func setDeviceTokenForPusNotifications(_ newValue: String?) async {
        deviceTokenForPusNotifications = newValue
    }
}
