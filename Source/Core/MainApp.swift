import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

extension UIApplicationShortcutItem: @unchecked Sendable {}

actor DeviceTokenActor {
    private var _deviceTokenForPusNotifications: String?

    var deviceTokenForPusNotifications: String? {
        get {
            return _deviceTokenForPusNotifications
        }
        set {
            _deviceTokenForPusNotifications = newValue
        }
    }

    func setDeviceTokenForPusNotifications(_ newValue: String?) async {
        _deviceTokenForPusNotifications = newValue
    }
}

actor QuickActionActor {
    private var _selectedQuickAction: UIApplicationShortcutItem?

    var selectedQuickAction: UIApplicationShortcutItem? {
        get {
            return _selectedQuickAction
        }
        set {
            _selectedQuickAction = newValue
        }
    }
    
    func setSelectedQuickAction(_ newValue: UIApplicationShortcutItem?) async {
        _selectedQuickAction = newValue
    }
}

let quickActionActor = QuickActionActor()
let deviceTokenActor = DeviceTokenActor()

private let logger = Logger(category: "Main")

@main
struct MainApp: App {
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
