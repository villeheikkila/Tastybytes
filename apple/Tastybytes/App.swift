import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

@main
struct Main: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  private let client = AppClient(url: Config.supabaseUrl, apiKey: Config.supabaseAnonKey)

  var body: some Scene {
    WindowGroup {
      RootView(client)
    }
  }
}

struct RootView: View {
  let client: AppClient
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var profileManager: ProfileManager
  @StateObject private var toastManager = ToastManager()
  @StateObject private var notificationManager: NotificationManager
  @StateObject private var hapticManager = HapticManager()
  @State private var authEvent: AuthChangeEvent?

  init(_ client: AppClient) {
    self.client = client
    _notificationManager = StateObject(wrappedValue: NotificationManager(client))
    _profileManager = StateObject(wrappedValue: ProfileManager(client))
  }

  var body: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn, let isOnboarded = profileManager.get().isOnboarded {
          if isOnboarded {
            TabsView(client)
          } else {
            OnboardTabsView(client)
              .onAppear {
                splashScreenManager.dismiss()
              }
          }
        }
      case .passwordRecovery:
        AuthenticationScreen(client, scene: .resetPassword)
      case .userDeleted:
        AuthenticationScreen(client, scene: .accountDeleted)
      case nil:
        SplashScreen()
      default:
        AuthenticationScreen(client, scene: .signIn)
      }
      if splashScreenManager.state != .finished {
        SplashScreen()
      }
    }
    .toast(isPresenting: $toastManager.show) {
      toastManager.toast
    }
    .environmentObject(splashScreenManager)
    .environmentObject(toastManager)
    .environmentObject(notificationManager)
    .environmentObject(profileManager)
    .environmentObject(hapticManager)
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
