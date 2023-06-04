import SwiftUI

enum Tab: Int, Identifiable, Hashable, CaseIterable {
  case activity, discover, notifications, admin, profile

  var id: Int {
    rawValue
  }

  var cachesPath: String {
    switch self {
    case .activity:
      return "activity"
    case .discover:
      return "discover"
    case .notifications:
      return "notifications"
    case .admin:
      return "admin"
    case .profile:
      return "profile"
    }
  }

  var cachesDirectoryPath: URL {
    URL.cachesDirectory.appending(path: cachesPath)
  }

  @ViewBuilder
  func view(selectedTab: Binding<Tab>, _ resetNavigationOnTab: Binding<Tab?>) -> some View {
    switch self {
    case .activity:
      ActivityTab(resetNavigationOnTab: resetNavigationOnTab, selectedTab: selectedTab)
    case .discover:
      DiscoverTab(resetNavigationOnTab: resetNavigationOnTab)
    case .notifications:
      NotificationTab(resetNavigationOnTab: resetNavigationOnTab)
    case .admin:
      AdminTab(resetNavigationOnTab: resetNavigationOnTab)
    case .profile:
      ProfileTab(resetNavigationOnTab: resetNavigationOnTab)
    }
  }

  @ViewBuilder var label: some View {
    switch self {
    case .activity:
      Label("Activity", systemSymbol: .listStar)
    case .discover:
      Label("Discover", systemSymbol: .magnifyingglass)
    case .notifications:
      Label("Notifications", systemSymbol: .bell)
    case .admin:
      Label("Admin", systemSymbol: .exclamationmarkLockFill)
    case .profile:
      Label("Profile", systemSymbol: .personFill)
    }
  }
}
