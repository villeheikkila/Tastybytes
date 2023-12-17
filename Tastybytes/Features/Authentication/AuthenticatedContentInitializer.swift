import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct AuthenticatedContentInitializer<Content: View>: View {
    private let logger = Logger(category: "MainContent")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(\.scenePhase) private var phase

    @ViewBuilder let content: () -> Content

    private let publisher = NotificationCenter.default
        .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived"))

    var body: some View {
        content()
            .onChange(of: phase) { _, newPhase in
                if newPhase == .active {
                    Task { await notificationEnvironmentModel.getUnreadCount()
                    }
                }
            }
            .onReceive(publisher) { notification in
                guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                      let unreadCount = aps["badge"] as? Int else { return }
                notificationEnvironmentModel.unreadCount = unreadCount
            }
            .task {
                await friendEnvironmentModel.initialize(profile: profileEnvironmentModel.profile)
            }
            .task {
                await notificationEnvironmentModel.getUnreadCount()
            }
    }
}
