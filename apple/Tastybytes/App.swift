import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

@main
struct Main: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  private let client = Client(url: Config.supabaseUrl, apiKey: Config.supabaseAnonKey)

  var body: some Scene {
    WindowGroup {
      RootView(client)
    }
  }
}

struct RootView: View {
  let client: Client
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var profileManager: ProfileManager
  @StateObject private var toastManager = ToastManager()
  @StateObject private var notificationManager: NotificationManager
  @State private var authEvent: AuthChangeEvent?

  init(_ client: Client) {
    self.client = client
    _notificationManager = StateObject(wrappedValue: NotificationManager(client))
    _profileManager = StateObject(wrappedValue: ProfileManager(client))
  }

  var body: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn {
          TabsView(client)
        }
      case .passwordRecovery:
        AuthenticationScreenView(client, scene: .resetPassword)
      case nil:
        SplashScreenView()
      default:
        AuthenticationScreenView(client, scene: .signIn)
      }
      if splashScreenManager.state != .finished {
        SplashScreenView()
      }
    }
    .toast(isPresenting: $toastManager.show) {
      toastManager.toast
    }
    .environmentObject(splashScreenManager)
    .environmentObject(toastManager)
    .environmentObject(notificationManager)
    .environmentObject(profileManager)
    .preferredColorScheme(profileManager.colorScheme)
    .onOpenURL { url in
      Task { _ = try await client.supabase.auth.session(from: url) }
    }
    .task {
      for await authEventChange in client.supabase.auth.authEventChange {
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

class AppDelegate: NSObject, UIApplicationDelegate {
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
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([[.banner, .sound]])
  }

  func userNotificationCenter(
    _: UNUserNotificationCenter,
    didReceive _: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
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
