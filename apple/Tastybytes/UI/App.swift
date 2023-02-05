import FirebaseCore
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
  @State private var authEvent: AuthChangeEvent?
  @StateObject private var notificationManager: NotificationManager

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
      Task { _ = try await client.supabaseClient.auth.session(from: url) }
    }
    .task {
      for await authEventChange in client.supabaseClient.auth.authEventChange {
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
