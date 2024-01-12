import Models
import SwiftUI

enum TabIdentifier: Hashable {
    case activity, discover, notifications, currentProfile
}

struct TabUrlHandler {
    private let url: URL
    let deeplinkSchema: String

    init(url: URL, deeplinkSchema: String) {
        self.url = url
        self.deeplinkSchema = deeplinkSchema
    }

    var isUniversalLink: Bool {
        url.scheme == "https"
    }

    var isDeepLink: Bool {
        url.scheme == deeplinkSchema
    }

    var tabIdentifier: TabIdentifier? {
        guard isUniversalLink || isDeepLink, url.pathComponents.count == 2 else { return nil }

        switch url.pathComponents[1] {
        case "activity": return .activity
        case "discover": return .discover
        case "notifications": return .notifications
        case "profile": return .currentProfile
        default: return nil
        }
    }

    var tab: Tab? {
        guard let identifier = tabIdentifier else { return nil }

        switch identifier {
        case .activity: return Tab.activity
        case .discover: return Tab.discover
        case .notifications: return Tab.notifications
        case .currentProfile: return Tab.profile
        }
    }

    var sidebarTab: SiderBarTab? {
        guard let identifier = tabIdentifier else { return nil }

        switch identifier {
        case .activity: return SiderBarTab.activity
        case .discover: return SiderBarTab.discover
        case .notifications: return SiderBarTab.notifications
        case .currentProfile: return SiderBarTab.profile
        }
    }
}
