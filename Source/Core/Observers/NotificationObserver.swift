
import Models
import Logging
import Repositories
import SwiftUI

struct NotificationObserver<Content: View>: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(Repository.self) private var repository
    @ViewBuilder let content: () -> Content

    var body: some View {
        InnerNotificationObserver(profileId: profileModel.id, repository: repository, content: content)
    }
}

private struct InnerNotificationObserver<Content: View>: View {
    private let logger = Logger(label: "MainContent")
    @Environment(AppModel.self) private var appModel
    @State private var notificationModel: NotificationModel
    @Environment(\.scenePhase) private var phase

    @ViewBuilder let content: () -> Content

    init(profileId: Profile.Id, repository: Repository, @ViewBuilder content: @escaping () -> Content) {
        _notificationModel = State(wrappedValue: NotificationModel(repository: repository, profileId: profileId))
        self.content = content
    }

    private let publisher = NotificationCenter.default
        .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived"))

    var body: some View {
        content()
            .environment(notificationModel)
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
            .onAppear {
                notificationModel.refresh()
            }
    }
}

actor DeviceTokenActor {
    static let shared = DeviceTokenActor()

    var deviceTokenForPusNotifications: DeviceToken.Id?

    private init() {}

    func setDeviceTokenForPusNotifications(_ newValue: DeviceToken.Id?) async {
        deviceTokenForPusNotifications = newValue
    }
}
