import SwiftUI

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var splashScreenManager = SplashScreenManager()
    @StateObject var toastManager = ToastManager()
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
