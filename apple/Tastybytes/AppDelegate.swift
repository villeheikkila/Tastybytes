import Firebase
import FirebaseMessaging
import RevenueCat
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions
    ) { _, _ in }

    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self

    Purchases.logLevel = .error
    Purchases.configure(withAPIKey: Config.revenuecatApiKey)

    return true
  }

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
  {
    let userInfo = notification.request.content.userInfo
    Messaging.messaging().appDidReceiveMessage(userInfo)
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
