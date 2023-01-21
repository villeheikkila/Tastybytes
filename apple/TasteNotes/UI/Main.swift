import SwiftUI

@main
struct Main: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var toastManager = ToastManager()
  private let notificationManager = NotificationManager()

  init() {
    UNUserNotificationCenter.current().delegate = notificationManager
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        RootView()
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
    }
  }
}
