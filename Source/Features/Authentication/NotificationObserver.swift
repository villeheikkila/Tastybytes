import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct NotificationObserver<Content: View>: View {
    private let logger = Logger(category: "MainContent")
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(\.scenePhase) private var phase

    @ViewBuilder let content: () -> Content

    private let publisher = NotificationCenter.default
        .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived"))

    var body: some View {
        content()
            .onChange(of: phase) { _, newPhase in
                if newPhase == .active {
                    Task { 
                        await notificationEnvironmentModel.getUnreadCount()
                    }
                }
            }
            .onReceive(publisher) { notification in
                guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                      let unreadCount = aps["badge"] as? Int else { return }
                notificationEnvironmentModel.unreadCount = unreadCount
            }
            .task {
                if let deviceTokenForPusNotifications = await deviceTokenActor.deviceTokenForPusNotifications {
                    await notificationEnvironmentModel.refreshDeviceToken(deviceToken: deviceTokenForPusNotifications)
                }
            }
            .onAppear {
                notificationEnvironmentModel.refresh()
            }
    }
}

actor DeviceTokenActor {
    var deviceTokenForPusNotifications: String?

    func setDeviceTokenForPusNotifications(_ newValue: String?) async {
        deviceTokenForPusNotifications = newValue
    }
}

let deviceTokenActor = DeviceTokenActor()
