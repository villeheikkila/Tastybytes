import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

/*
 This global variable is here to share state between AppDelegate, SceneDelegate and Main app
 TODO: Figure out a better way to pass this state.
 */
var selectedQuickAction: UIApplicationShortcutItem?

private let logger = Logger(category: "Main")

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    @Environment(\.scenePhase) private var phase
    @Environment(\.repository) private var repository

    var body: some Scene {
        WindowGroup {
            EnvironmentProvider(repository: repository)
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
