import FirebaseCore
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

@main
struct Main: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var profileManager = ProfileManager()
  @StateObject private var toastManager = ToastManager()
  @State private var authEvent: AuthChangeEvent?
  private let notificationManager = NotificationManager()

  init() {
    UNUserNotificationCenter.current().delegate = notificationManager
  }

  var body: some Scene {
    WindowGroup {
      rootView
        .toast(isPresenting: $toastManager.show) {
          toastManager.toast
        }
        .environmentObject(splashScreenManager)
        .environmentObject(toastManager)
        .environmentObject(notificationManager)
        .environmentObject(profileManager)
        .preferredColorScheme(profileManager.colorScheme)
        .onOpenURL { url in
          Task { _ = try await supabaseClient.auth.session(from: url) }
        }
        .task {
          for await authEventChange in supabaseClient.auth.authEventChange {
            withAnimation {
              self.authEvent = authEventChange
            }
            switch authEvent {
            case .signedIn:
              Task {
                profileManager.refresh()
                notificationManager.refresh()
                notificationManager.refreshAPNS()
              }
            default:
              break
            }
          }
        }
    }
  }

  private var rootView: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn {
          TabsView()
        }
      case nil:
        SplashScreenView()
      default:
        AuthenticationScreenView()
      }

      if splashScreenManager.state != .finished {
        SplashScreenView()
      }
    }
  }
}

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
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any])
  {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)
  }

  func application(_: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult
  {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    return UIBackgroundFetchResult.newData
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
