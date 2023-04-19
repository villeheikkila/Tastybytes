import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

@main
struct Main: App {
  @StateObject private var feedbackManager = FeedbackManager()
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  private let supabaseClient = SupabaseClient(
    supabaseURL: Config.supabaseUrl,
    supabaseKey: Config.supabaseAnonKey
  )

  var body: some Scene {
    WindowGroup {
      RootView(supabaseClient: supabaseClient, feedbackManager: feedbackManager)
    }
  }
}

struct RootView: View {
  let supabaseClient: SupabaseClient
  @StateObject private var repository: Repository
  @StateObject private var splashScreenManager = SplashScreenManager()
  @StateObject private var profileManager: ProfileManager
  @StateObject private var notificationManager: NotificationManager
  @StateObject private var appDataManager: AppDataManager
  @State private var authEvent: AuthChangeEvent?
  @ObservedObject private var feedbackManager: FeedbackManager

  init(supabaseClient: SupabaseClient, feedbackManager: FeedbackManager) {
    let repository = Repository(supabaseClient: supabaseClient)
    self.supabaseClient = supabaseClient
    _repository = StateObject(wrappedValue: repository)
    _notificationManager =
      StateObject(wrappedValue: NotificationManager(repository: repository, feedbackManager: feedbackManager))
    _profileManager = StateObject(wrappedValue: ProfileManager(repository: repository, feedbackManager: feedbackManager))
    _appDataManager = StateObject(wrappedValue: AppDataManager(repository: repository, feedbackManager: feedbackManager))
    self.feedbackManager = feedbackManager
  }

  var body: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn {
          if profileManager.get().isOnboarded {
            TabsView(repository, profile: profileManager.getProfile(), feedbackManager: feedbackManager)
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
    .toast(isPresenting: $feedbackManager.show) {
      feedbackManager.toast
    }
    .environmentObject(repository)
    .environmentObject(splashScreenManager)
    .environmentObject(notificationManager)
    .environmentObject(profileManager)
    .environmentObject(feedbackManager)
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
          await profileManager.initialize()
          await notificationManager.refresh()
          notificationManager.refreshAPNS()
        default:
          break
        }
      }
    }
  }
}
