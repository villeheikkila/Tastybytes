import Firebase
import FirebaseMessaging
import GoTrue
import Supabase
import SwiftUI

/*
 This global variable is here to share state between AppDelegate, SceneDelegate and Main app
 TODO: Figure out a better way to pass this state.
 */
var selectedQuickAction: UIApplicationShortcutItem?

@main
struct Main: App {
  private let logger = getLogger(category: "Main")
  @Environment(\.scenePhase) private var phase
  @Bindable private var feedbackManager = FeedbackManager()
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
    .onChange(of: phase) { _, newPhase in
      switch newPhase {
      case .active:
        logger.info("scene phase is active")
        if let name = selectedQuickAction?.userInfo?["name"] as? String, let quickAction = QuickAction(rawValue: name) {
          UIApplication.shared.open(quickAction.url)
          selectedQuickAction = nil
        }
      case .inactive:
        logger.info("scene phase is inactive")
      case .background:
        logger.info("scene phase is background")
        UIApplication.shared.shortcutItems = QuickAction.allCases.map(\.shortcutItem)
      @unknown default:
        logger.info("scene phase is unknown")
      }
    }
  }
}

struct RootView: View {
  private let logger = getLogger(category: "RootView")
  let supabaseClient: SupabaseClient
  @State private var repository: Repository
  @State private var splashScreenManager = SplashScreenManager()
  @State private var permissionManager = PermissionManager()
  @State private var profileManager: ProfileManager
  @State private var notificationManager: NotificationManager
  @State private var appDataManager: AppDataManager
  @State private var friendManager: FriendManager
  @State private var imageUploadManager: ImageUploadManager
  @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false
  @AppStorage(.colorScheme) var colorScheme: String = "system"
  @Environment(\.scenePhase) private var phase
  @State private var authEvent: AuthChangeEvent?
  @State private var orientation: UIDeviceOrientation
  let feedbackManager: FeedbackManager

  init(supabaseClient: SupabaseClient, feedbackManager: FeedbackManager) {
    let repository = Repository(supabaseClient: supabaseClient)
    self.supabaseClient = supabaseClient
    _repository = State(wrappedValue: repository)
    _notificationManager =
      State(wrappedValue: NotificationManager(repository: repository, feedbackManager: feedbackManager))
    _profileManager = State(wrappedValue: ProfileManager(repository: repository, feedbackManager: feedbackManager))
    _appDataManager = State(wrappedValue: AppDataManager(repository: repository, feedbackManager: feedbackManager))
    _imageUploadManager =
      State(wrappedValue: ImageUploadManager(repository: repository, feedbackManager: feedbackManager))
    _friendManager =
      State(wrappedValue: FriendManager(repository: repository, feedbackManager: feedbackManager))
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
    .environment(repository)
    .environment(splashScreenManager)
    .environment(notificationManager)
    .environment(profileManager)
    .environment(feedbackManager)
    .environment(appDataManager)
    .environment(friendManager)
    .environment(permissionManager)
    .environment(imageUploadManager)
    .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
    .detectOrientation($orientation)
    .environment(\.orientation, orientation)
    .onOpenURL { url in
      Task {
        await loadSessionFromURL(url: url)
      }
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
    } else if !isOnboardedOnDevice {
      OnboardingScreen()
    } else {
      Group {
        if isPadOrMac() {
          SideBarView()
        } else {
          TabsView()
        }
      }
      .onChange(of: phase) { _, newPhase in
        if newPhase == .active {
          Task { await notificationManager.getUnreadCount()
          }
        }
      }
      .onReceive(NotificationCenter.default
        .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived")))
      { notification in
        guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
              let unreadCount = aps["badge"] as? Int else { return }
        notificationManager.unreadCount = unreadCount
      }
      .task {
        await friendManager.initialize(profile: profileManager.profile)
        await notificationManager.getUnreadCount()
      }
    }
  }

  func loadSessionFromURL(url: URL) async {
    do {
      _ = try await supabaseClient.auth.session(from: url)
    } catch {
      logger.error("failed to load session from url: \(url): \(error.localizedDescription)")
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
