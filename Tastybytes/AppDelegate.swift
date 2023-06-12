import Firebase
import FirebaseMessaging
import OSLog
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(category: "AppDelegate")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        URLCache.shared.memoryCapacity = 50_000_000
        URLCache.shared.diskCapacity = 1_000_000_000

        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

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
        // Reset tab restoration
        UserDefaults.standard.removeObject(for: .selectedTab)

        // Reset NavigationStack restoration
        let fileManager = FileManager.default
        let filesToDelete = Tab.allCases.map(\.cachesPath)
        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: URL.cachesDirectory,
                includingPropertiesForKeys: nil,
                options: []
            )
            for file in directoryContents where filesToDelete.contains(file.lastPathComponent) {
                try fileManager.removeItem(at: file)
            }
        } catch {
            logger.error("Failed to delete navigation stack state restoration files. Error: \(error) (\(#file):\(#line))")
        }
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
        Messaging.messaging().appDidReceiveMessage(userInfo)
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
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }

    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Firebase.Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
    }
}
