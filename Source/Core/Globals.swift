import SwiftUI

extension UIApplicationShortcutItem: @unchecked Sendable {}

actor DeviceTokenActor {
    private var _deviceTokenForPusNotifications: String?

    var deviceTokenForPusNotifications: String? {
        get {
            _deviceTokenForPusNotifications
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
            _selectedQuickAction
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
