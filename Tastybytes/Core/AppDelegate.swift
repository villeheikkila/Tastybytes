import EnvironmentModels
import OSLog
import SwiftUI

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
            selectedQuickAction = shortcutItem
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
        selectedQuickAction = shortcutItem
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

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let deepLink = userInfo["link"] as? String, let url = URL(string: deepLink) {
            UIApplication.shared.open(url)
        }
        completionHandler()
    }

    func application(_: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        deviceTokenForPusNotifications = deviceTokenString
    }
}
