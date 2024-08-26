import Models
import SwiftUI

struct TabUrlHandler {
    private let url: URL
    private let deeplinkSchemes: [String]

    init(url: URL, deeplinkSchemes: [String]) {
        self.url = url
        self.deeplinkSchemes = deeplinkSchemes
    }

    var isUniversalLink: Bool {
        url.scheme == "https"
    }

    var isDeepLink: Bool {
        guard let scheme = url.scheme else { return false }
        return deeplinkSchemes.contains(scheme)
    }

    var tabIdentifier: Tabs? {
        guard isUniversalLink || isDeepLink, url.pathComponents.count == 2 else { return nil }

        switch url.pathComponents[1] {
        case Tabs.activity.identifier: return .activity
        case Tabs.discover.identifier: return .discover
        case Tabs.notifications.identifier: return .notifications
        case Tabs.profile.identifier: return .profile
        default: return nil
        }
    }

    var tab: Tabs? {
        guard let tabIdentifier else { return nil }
        switch tabIdentifier {
        case .activity: return .activity
        case .discover: return .discover
        case .notifications: return .notifications
        case .profile: return .profile
        case .admin: return .admin
        }
    }
}
