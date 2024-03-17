import EnvironmentModels
import OSLog
import SwiftUI

// HACK: Remove when no longer necessary
extension UNUserNotificationCenter: @unchecked Sendable {}
extension UNNotification: @unchecked Sendable {}
extension UIApplicationShortcutItem: @unchecked Sendable {}

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(category: "AppDelegate")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        URLCache.shared.memoryCapacity = 50_000_000 // 50M
        URLCache.shared.diskCapacity = 200_000_000 // 200MB
        return true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            Task {
                await quickActionActor.setSelectedQuickAction(shortcutItem)
            }
        }

        let sceneConfiguration = UISceneConfiguration(
            name: "Scene Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneConfiguration.self

        return sceneConfiguration
    }

    func applicationWillTerminate(_: UIApplication) {
        clearTemporaryData()
    }
}

class SceneConfiguration: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler _: @escaping (Bool) -> Void
    ) {
        Task {
            await quickActionActor.setSelectedQuickAction(shortcutItem)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
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
            await deviceTokenActor.setDeviceTokenForPusNotifications(deviceTokenString)
        }
    }
}

// Actors to make passing values between AppDelegate and SwiftUI views safe without using shared singletons

actor QuickActionActor {
    var selectedQuickAction: UIApplicationShortcutItem?

    func setSelectedQuickAction(_ newValue: UIApplicationShortcutItem?) async {
        selectedQuickAction = newValue
    }
}

let quickActionActor = QuickActionActor()
