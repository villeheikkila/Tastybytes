import FirebaseCore
import FirebaseMessaging
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  let gcmMessageIDKey = "gcm.message_id"

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions _: [UIApplication
                     .LaunchOptionsKey: Any]?) -> Bool
  {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()
    return true
  }

  func application(_: UIApplication,
                   didReceiveRemoteNotification _: [AnyHashable: Any]) {}

  func application(_: UIApplication,
                   didReceiveRemoteNotification _: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult
  {
    UIBackgroundFetchResult.newData
  }

  func application(_: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error)
  {
    print("Unable to register for remote notifications: \(error.localizedDescription)")
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: FirebaseMessaging.Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
