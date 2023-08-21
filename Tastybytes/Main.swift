import EnvironmentModels
import Firebase
import FirebaseMessaging
import Models
import OSLog
import Supabase
import SwiftUI

/*
 This global variable is here to share state between AppDelegate, SceneDelegate and Main app
 TODO: Figure out a better way to pass this state.
 */
var selectedQuickAction: UIApplicationShortcutItem?

@main
struct Main: App {
    private let logger = Logger(category: "Main")
    @Environment(\.scenePhase) private var phase
    @Bindable private var feedbackEnvironmentModel = FeedbackEnvironmentModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    private let supabaseClient = SupabaseClient(
        supabaseURL: Config.supabaseUrl,
        supabaseKey: Config.supabaseAnonKey
    )

    var body: some Scene {
        WindowGroup {
            RootView(supabaseClient: supabaseClient, feedbackEnvironmentModel: feedbackEnvironmentModel)
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
