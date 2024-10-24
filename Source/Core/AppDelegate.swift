
import Logging
import SwiftUI

@MainActor func applyNavigationBarUITweaks(application _: UIApplication) {
    UINavigationBar.appearance().shadowImage = .init()
}

@MainActor func applyTabBarUITweaks(application _: UIApplication) {
    UITabBar.appearance().clipsToBounds = true
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    nonisolated func getNotificationAuthorizationStatus() async -> sending UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        return await center.notificationSettings().authorizationStatus
    }

    private let logger = Logger(label: "AppDelegate")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Task {
            let center = UNUserNotificationCenter.current()
            let authorizationStatus = await getNotificationAuthorizationStatus()

            if authorizationStatus != .authorized ||
                authorizationStatus != .provisional
            {
                do {
                    try await center.requestAuthorization(
                        options: [.alert, .sound, .badge, .provisional]
                    )
                } catch {
                    print("Error requesting notification authorization: \(error)")
                }
            }
        }
        application.registerForRemoteNotifications()
        applyNavigationBarUITweaks(application: application)
        applyTabBarUITweaks(application: application)
        return true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            Task {
                await QuickActionActor.shared.setSelectedQuickAction(shortcutItem)
            }
        }

        let sceneConfiguration = UISceneConfiguration(
            name: "Scene Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneConfiguration.self

        return sceneConfiguration
    }
}

class SceneConfiguration: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler _: @escaping (Bool) -> Void
    ) {
        Task {
            await QuickActionActor.shared.setSelectedQuickAction(shortcutItem)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
    {
        let userInfo = notification.request.content.userInfo
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "PushNotificationReceived"),
            object: nil,
            userInfo: userInfo
        )
        return [.sound, .badge, .banner, .list]
    }

    nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let deepLink = userInfo["link"] as? String, let url = URL(string: deepLink) {
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
        }
        completionHandler()
    }

    func application(_: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        Task {
            await DeviceTokenActor.shared.setDeviceTokenForPusNotifications(.init(rawValue: deviceTokenString))
        }
    }
}

actor QuickActionActor {
    static let shared = QuickActionActor()

    private init() {}

    private var selectedQuickAction: QuickAction?

    func readAndClearSelectedQuickAction() -> QuickAction? {
        defer {
            selectedQuickAction = nil
        }
        return selectedQuickAction
    }

    func setSelectedQuickAction(_ newValue: UIApplicationShortcutItem?) async {
        if let name = newValue?.userInfo?["name"] as? String,
           let quickAction = QuickAction(rawValue: name)
        {
            selectedQuickAction = quickAction
        } else {
            selectedQuickAction = nil
        }
    }
}
