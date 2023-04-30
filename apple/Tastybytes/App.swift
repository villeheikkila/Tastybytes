import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

extension UIDevice {
  var isCatalystMacIdiom: Bool {
    if #available(iOS 14, *) {
      return UIDevice.current.userInterfaceIdiom == .mac
    } else {
      return false
    }
  }
}

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
  @StateObject private var friendManager: FriendManager
  @StateObject private var purchaseManager: PurchaseManager
  @State private var authEvent: AuthChangeEvent?
  @State private var orientation: UIDeviceOrientation
  @ObservedObject private var feedbackManager: FeedbackManager

  init(supabaseClient: SupabaseClient, feedbackManager: FeedbackManager) {
    let repository = Repository(supabaseClient: supabaseClient)
    self.supabaseClient = supabaseClient
    _repository = StateObject(wrappedValue: repository)
    _notificationManager =
      StateObject(wrappedValue: NotificationManager(repository: repository, feedbackManager: feedbackManager))
    _profileManager = StateObject(wrappedValue: ProfileManager(repository: repository, feedbackManager: feedbackManager))
    _appDataManager = StateObject(wrappedValue: AppDataManager(repository: repository, feedbackManager: feedbackManager))
    _purchaseManager = StateObject(wrappedValue: PurchaseManager(feedbackManager: feedbackManager))
    _friendManager =
      StateObject(wrappedValue: FriendManager(repository: repository, feedbackManager: feedbackManager))
    _orientation = State(wrappedValue: UIDevice.current.orientation)
    self.feedbackManager = feedbackManager
  }

  var body: some View {
    ZStack {
      switch authEvent {
      case .signedIn:
        signedInContent
      case .passwordRecovery:
        AuthenticationScreen(scene: .resetPassword)
      case .userDeleted:
        AuthenticationScreen(scene: .accountDeleted)
      case nil:
        if !isMac() {
          SplashScreen()
        } else {
          EmptyView()
        }
      default:
        AuthenticationScreen(scene: .signIn)
      }
      if !isMac(), splashScreenManager.state != .finished {
        SplashScreen()
      }
    }
    .environmentObject(repository)
    .environmentObject(splashScreenManager)
    .environmentObject(notificationManager)
    .environmentObject(profileManager)
    .environmentObject(feedbackManager)
    .environmentObject(appDataManager)
    .environmentObject(purchaseManager)
    .environmentObject(friendManager)
    .preferredColorScheme(profileManager.colorScheme)
    .detectOrientation($orientation)
    .environment(\.orientation, orientation)
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

  @ViewBuilder private var signedInContent: some View {
    if !profileManager.isLoggedIn {
      EmptyView()
    } else if !profileManager.isOnboarded {
      OnboardTabsView()
    } else {
      Group {
        if isPadOrMac() {
          SideBarView()
        } else {
          TabsView()
        }
      }
      .task {
        await friendManager.initialize(profile: profileManager.profile)
        purchaseManager.initialize()
      }
    }
  }
}

struct Orientation: EnvironmentKey {
  static let defaultValue: UIDeviceOrientation = UIDevice.current.orientation
}

extension EnvironmentValues {
  var orientation: UIDeviceOrientation {
    get { self[Orientation.self] }
    set { self[Orientation.self] = newValue }
  }
}
