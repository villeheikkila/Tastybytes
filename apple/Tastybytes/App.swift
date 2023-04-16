import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

@main
struct Main: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  private let supabaseClient = SupabaseClient(
    supabaseURL: Config.supabaseUrl,
    supabaseKey: Config.supabaseAnonKey
  )

  var body: some Scene {
    WindowGroup {
      RootView(supabaseClient: supabaseClient)
    }
  }
}

struct RootView: View {
  let supabaseClient: SupabaseClient
  @StateObject private var repository: Repository
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var profileManager: ProfileManager
  @StateObject private var toastManager = ToastManager()
  @StateObject private var notificationManager: NotificationManager
  @StateObject private var hapticManager = HapticManager()
  @StateObject private var appDataManager: AppDataManager
  @State private var authEvent: AuthChangeEvent?

  init(supabaseClient: SupabaseClient) {
    let repository = Repository(supabaseClient: supabaseClient)
    self.supabaseClient = supabaseClient
    _repository = StateObject(wrappedValue: repository)
    _notificationManager = StateObject(wrappedValue: NotificationManager(repository: repository))
    _profileManager = StateObject(wrappedValue: ProfileManager(repository: repository))
    _appDataManager = StateObject(wrappedValue: AppDataManager(repository: repository))
  }

  var body: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn {
          if profileManager.get().isOnboarded {
            TabsView(repository, profile: profileManager.getProfile())
          } else {
            OnboardTabsView()
          }
        }
      case .passwordRecovery:
        AuthenticationScreen(scene: .resetPassword)
      case .userDeleted:
        AuthenticationScreen(scene: .accountDeleted)
      case nil:
        SplashScreen()
      default:
        AuthenticationScreen(scene: .signIn)
      }
      if splashScreenManager.state != .finished {
        SplashScreen()
      }
    }
    .toast(isPresenting: $toastManager.show) {
      toastManager.toast
    }
    .environmentObject(repository)
    .environmentObject(splashScreenManager)
    .environmentObject(toastManager)
    .environmentObject(notificationManager)
    .environmentObject(profileManager)
    .environmentObject(hapticManager)
    .environmentObject(appDataManager)
    .preferredColorScheme(profileManager.colorScheme)
    .onOpenURL { url in
      Task { _ = try await supabaseClient.auth.session(from: url) }
    }
    .task {
      if !appDataManager.isInitialized {
        await appDataManager.initialize()
      }
    }
    .task {
      for await authEventChange in supabaseClient.auth.authEventChange {
        withAnimation {
          authEvent = authEventChange
        }
        switch authEvent {
        case .signedIn:
          await profileManager.refresh()
          await notificationManager.refresh()
          notificationManager.refreshAPNS()
        default:
          break
        }
      }
    }
  }
}
