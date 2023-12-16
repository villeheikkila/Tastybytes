import Models
import SwiftUI

enum TabIdentifier: Hashable {
    case activity, discover, notifications, currentProfile
}

extension URL {
    var tabIndentifier: TabIdentifier? {
        guard isUniversalLink || isDeepLink, pathComponents.count == 2 else { return nil }

        return switch pathComponents[1] {
        case "activity": .activity
        case "discover": .discover
        case "notifications": .notifications
        case "profile": .currentProfile
        default: nil
        }
    }

    var tab: Tab? {
        guard let tabIndentifier
        else {
            return nil
        }

        return switch tabIndentifier {
        case .activity:
            Tab.activity
        case .discover:
            Tab.discover
        case .notifications:
            Tab.notifications
        case .currentProfile:
            Tab.profile
        }
    }

    var sidebarTab: SiderBarTab? {
        guard let tabIndentifier
        else {
            return nil
        }

        return switch tabIndentifier {
        case .activity:
            SiderBarTab.activity
        case .discover:
            SiderBarTab.discover
        case .notifications:
            SiderBarTab.notifications
        case .currentProfile:
            SiderBarTab.profile
        }
    }
}
