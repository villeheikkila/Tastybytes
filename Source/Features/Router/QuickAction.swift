import Models
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
            .init(
                type: "Activity",
                localizedTitle: "tab.activity",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemImageName: "list.star"),
                userInfo: ["name": "activity" as NSSecureCoding]
            )
        case .discover:
            .init(
                type: "Discover",
                localizedTitle: "tab.discover",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"),
                userInfo: ["name": "discover" as NSSecureCoding]
            )
        case .notifications:
            .init(
                type: "Notifications",
                localizedTitle: "tab.notifications",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemImageName: "bell"),
                userInfo: ["name": "notifications" as NSSecureCoding]
            )
        case .profile:
            .init(
                type: "Profile",
                localizedTitle: "tab.profile",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemImageName: "person.fill"),
                userInfo: ["name": "profile" as NSSecureCoding]
            )
        }
    }

    var path: String {
        switch self {
        case .activity:
            "activity"
        case .discover:
            "discover"
        case .notifications:
            "notifications"
        case .profile:
            "profile"
        }
    }

    func getUrl(baseUrl: URL) -> URL {
        baseUrl.appendingPathComponent(path)
    }
}
