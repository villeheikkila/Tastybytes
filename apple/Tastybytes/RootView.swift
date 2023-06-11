import GoTrue
import OSLog
import Supabase
import SwiftUI

struct RootView: View {
    private let logger = Logger(category: "RootView")
    let supabaseClient: SupabaseClient
    @State private var repository: Repository
    @State private var splashScreenManager = SplashScreenManager()
    @State private var permissionManager = PermissionManager()
    @State private var profileManager: ProfileManager
    @State private var notificationManager: NotificationManager
    @State private var appDataManager: AppDataManager
    @State private var friendManager: FriendManager
    @State private var imageUploadManager: ImageUploadManager
    @AppStorage(.colorScheme) var colorScheme: String = "system"
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
                AuthenticatedContent()
            case .passwordRecovery:
                AuthenticationScreen(scene: .resetPassword)
            case .userDeleted:
                AuthenticationScreen(scene: .accountDeleted)
            case nil:
                SplashScreen()
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
            await appDataManager.initialize()
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

    func loadSessionFromURL(url: URL) async {
        do {
            _ = try await supabaseClient.auth.session(from: url)
        } catch {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
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

struct AuthenticatedContent: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FriendManager.self) private var friendManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.scenePhase) private var phase
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false

    var body: some View {
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
}