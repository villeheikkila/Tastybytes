import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@main
struct MainApp: App {
    private let logger = Logger(category: "Main")
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .active:
                logger.info("Scene phase is active.")
                Task {
                    let quickAction = await quickActionActor.selectedQuickAction
                    if let name = quickAction?.userInfo?["name"] as? String,
                       let quickAction = QuickAction(rawValue: name)
                    {
                        await UIApplication.shared.open(quickAction.url)
                        await quickActionActor.setSelectedQuickAction(nil)
                    }
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
