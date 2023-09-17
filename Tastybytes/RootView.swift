import EnvironmentModels
import GoTrue
import OSLog
import Repositories
import StoreKit
import Supabase
import SwiftUI
import TipKit

struct RepositoryKey: EnvironmentKey {
    static var defaultValue: RepositoryProtocol? = nil
}

extension EnvironmentValues {
    var repository: RepositoryProtocol {
        get {
            guard let currentValue = self[RepositoryKey.self]
            else { fatalError("Repository has not been added to the environment") }
            return currentValue
        }
        set { self[RepositoryKey.self] = newValue }
    }
}

struct RootView: View {
    private let logger = Logger(category: "RootView")
    let supabaseClient: SupabaseClient
    @State private var splashScreenEnvironmentModel = SplashScreenEnvironmentModel()
    @State private var permissionEnvironmentModel = PermissionEnvironmentModel()
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appDataEnvironmentModel: AppDataEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var subscriptionEnvironmentModel = SubscriptionEnvironmentModel()
    @AppStorage(.colorScheme) var colorScheme: String = "system"
    @State private var authEvent: AuthChangeEvent?
    @State private var orientation: UIDeviceOrientation
    let feedbackEnvironmentModel: FeedbackEnvironmentModel

    init(supabaseClient: SupabaseClient, feedbackEnvironmentModel: FeedbackEnvironmentModel) {
        let repository = Repository(supabaseClient: supabaseClient)
        self.supabaseClient = supabaseClient
        _notificationEnvironmentModel =
            State(wrappedValue: NotificationEnvironmentModel(repository: repository,
                                                             feedbackEnvironmentModel: feedbackEnvironmentModel))
        _profileEnvironmentModel =
            State(wrappedValue: ProfileEnvironmentModel(repository: repository,
                                                        feedbackEnvironmentModel: feedbackEnvironmentModel))
        _appDataEnvironmentModel =
            State(wrappedValue: AppDataEnvironmentModel(repository: repository,
                                                        feedbackEnvironmentModel: feedbackEnvironmentModel))
        _imageUploadEnvironmentModel =
            State(wrappedValue: ImageUploadEnvironmentModel(repository: repository,
                                                            feedbackEnvironmentModel: feedbackEnvironmentModel))
        _friendEnvironmentModel =
            State(wrappedValue: FriendEnvironmentModel(repository: repository,
                                                       feedbackEnvironmentModel: feedbackEnvironmentModel))
        _orientation = State(wrappedValue: UIDevice.current.orientation)
        self.feedbackEnvironmentModel = feedbackEnvironmentModel
    }

    var body: some View {
        ZStack {
            switch authEvent {
            case .signedIn:
                AuthenticatedContent()
            case .passwordRecovery:
                AuthenticationScreen(authenticationScene: .emailPassword(.resetPassword))
            case nil:
                SplashScreen()
            default:
                AuthenticationScreen()
            }
            if !isMac(), splashScreenEnvironmentModel.state != .finished {
                SplashScreen()
            }
        }
        .environment(\.repository, Repository(supabaseClient: supabaseClient))
        .environment(splashScreenEnvironmentModel)
        .environment(notificationEnvironmentModel)
        .environment(profileEnvironmentModel)
        .environment(feedbackEnvironmentModel)
        .environment(appDataEnvironmentModel)
        .environment(friendEnvironmentModel)
        .environment(permissionEnvironmentModel)
        .environment(imageUploadEnvironmentModel)
        .environment(subscriptionEnvironmentModel)
        .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
        .detectOrientation($orientation)
        .environment(\.orientation, orientation)
        .onOpenURL { url in
            Task {
                await loadSessionFromURL(url: url)
            }
        }
        .task {
            try? Tips.configure([.displayFrequency(.daily)])
        }
        .task {
            permissionEnvironmentModel.initialize()
        }
        .task {
            await appDataEnvironmentModel.initialize()
        }
        .task {
            for await authEventChange in supabaseClient.auth.authEventChange {
                withAnimation {
                    authEvent = authEventChange
                }
                switch authEvent {
                case .signedIn:
                    await profileEnvironmentModel.initialize()
                    notificationEnvironmentModel.refreshAPNS()
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
    private let logger = Logger(category: "AuthenticatedContent")
    @State private var status: EntitlementTaskState<SubscriptionStatus> = .loading
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @Environment(\.scenePhase) private var phase
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false

    var body: some View {
        if !profileEnvironmentModel.isLoggedIn {
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
                    Task { await notificationEnvironmentModel.getUnreadCount()
                    }
                }
            }
            .onReceive(NotificationCenter.default
                .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived")))
            { notification in
                guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                      let unreadCount = aps["badge"] as? Int else { return }
                notificationEnvironmentModel.unreadCount = unreadCount
            }
            .task {
                await friendEnvironmentModel.initialize(profile: profileEnvironmentModel.profile)
                await notificationEnvironmentModel.getUnreadCount()
            }
            .onAppear(perform: {
                ProductSubscription.createSharedInstance()
            })
            .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
                self.status = await taskStatus.map { statuses in
                    await ProductSubscription.shared.status(
                        for: statuses,
                        ids: productSubscriptionIds
                    )
                }
                switch self.status {
                case let .failure(error):
                    subscriptionEnvironmentModel.subscriptionStatus = .notSubscribed
                    logger.error("Failed to check subscription status: \(error)")
                case let .success(status):
                    subscriptionEnvironmentModel.subscriptionStatus = status
                case .loading: break
                @unknown default: break
                }
            }
            .task {
                await ProductSubscription.shared.observeTransactionUpdates()
                await ProductSubscription.shared.checkForUnfinishedTransactions()
            }
        }
    }
}
