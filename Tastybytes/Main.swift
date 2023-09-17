import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

public struct RepositoryKey: EnvironmentKey {
    public static var defaultValue: Repository = .init(
        supabaseURL: Config.supabaseUrl,
        supabaseKey: Config.supabaseAnonKey
    )
}

public extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryKey.self] }
        set { self[RepositoryKey.self] = newValue }
    }
}

/*
 This global variable is here to share state between AppDelegate, SceneDelegate and Main app
 TODO: Figure out a better way to pass this state.
 */
var selectedQuickAction: UIApplicationShortcutItem?

@main
struct Main: App {
    private let logger = Logger(category: "Main")
    @Environment(\.scenePhase) private var phase
    @Environment(\.repository) private var repository

    @Bindable private var feedbackEnvironmentModel = FeedbackEnvironmentModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(repository: repository, feedbackEnvironmentModel: feedbackEnvironmentModel)
        }
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .active:
                logger.info("Scene phase is active.")
                if let name = selectedQuickAction?.userInfo?["name"] as? String,
                   let quickAction = QuickAction(rawValue: name)
                {
                    UIApplication.shared.open(quickAction.url)
                    selectedQuickAction = nil
                }
            case .inactive:
                logger.info("Scene phase is inactive.")
            case .background:
                logger.info("Scene phase is background.")
                UIApplication.shared.shortcutItems = QuickAction.allCases.map(\.shortcutItem)
            @unknown default:
                logger.info("Scene phase is unknown.")
            }
        }
    }
}
