import SwiftUI

enum QuickAction: String, Hashable, CaseIterable, Identifiable {
    var id: String {
        rawValue
    }

    case activity
    case discover
    case notifications
    case profile

    var shortcutItem: UIApplicationShortcutItem {
        switch self {
        case .activity:
            UIApplicationShortcutItem(
                type: "Activity",
                localizedTitle: "Activity",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemSymbol: .listStar),
                userInfo: ["name": "activity" as NSSecureCoding]
            )
        case .discover:
            UIApplicationShortcutItem(
                type: "Discover",
                localizedTitle: "Discover",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemSymbol: .magnifyingglass),
                userInfo: ["name": "discover" as NSSecureCoding]
            )
        case .notifications:
            UIApplicationShortcutItem(
                type: "Notifications",
                localizedTitle: "Notifications",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemSymbol: .bell),
                userInfo: ["name": "notifications" as NSSecureCoding]
            )
        case .profile:
            UIApplicationShortcutItem(
                type: "Profile",
                localizedTitle: "Profile",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemSymbol: .personFill),
                userInfo: ["name": "profile" as NSSecureCoding]
            )
        }
    }

    var urlString: String {
        switch self {
        case .activity:
            "\(Config.deeplinkBaseUrl)/activity"
        case .discover:
            "\(Config.deeplinkBaseUrl)/discover"
        case .notifications:
            "\(Config.deeplinkBaseUrl)/notifications"
        case .profile:
            "\(Config.deeplinkBaseUrl)/profile"
        }
    }

    var url: URL {
        // swiftlint:disable force_unwrapping
        URL(string: urlString)!
        // swiftlint:enable force_unwrapping
    }
}
