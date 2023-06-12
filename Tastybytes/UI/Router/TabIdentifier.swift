import SwiftUI

enum TabIdentifier: Hashable {
  case activity, discover, notifications, currentProfile
}

extension URL {
  var tabIndentifier: TabIdentifier? {
    guard isUniversalLink || isDeepLink, pathComponents.count == 2 else { return nil }

    switch pathComponents[1] {
    case "activity": return .activity
    case "discover": return .discover
    case "notifications": return .notifications
    case "profile": return .currentProfile
    default: return nil
    }
  }

  var tab: Tab? {
    guard let tabIndentifier
    else {
      return nil
    }

    switch tabIndentifier {
    case .activity:
      return Tab.activity
    case .discover:
      return Tab.discover
    case .notifications:
      return Tab.notifications
    case .currentProfile:
      return Tab.profile
    }
  }

  var sidebarTab: SiderBarTab? {
    guard let tabIndentifier
    else {
      return nil
    }

    switch tabIndentifier {
    case .activity:
      return SiderBarTab.activity
    case .discover:
      return SiderBarTab.discover
    case .notifications:
      return SiderBarTab.notifications
    case .currentProfile:
      return SiderBarTab.profile
    }
  }
}
