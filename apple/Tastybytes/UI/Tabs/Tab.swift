import SwiftUI

enum Tab: Int, Identifiable, Hashable {
  case activity, search, notifications, admin, profile

  var id: Int {
    rawValue
  }

  @ViewBuilder
  func view(_ resetNavigationOnTab: Binding<Tab?>) -> some View {
    switch self {
    case .activity:
      ActivityTab(resetNavigationOnTab: resetNavigationOnTab)
    case .search:
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
      Label("Activity", systemImage: "list.star")
    case .search:
      Label("Discover", systemImage: "magnifyingglass")
    case .notifications:
      Label("Notifications", systemImage: "bell")
    case .admin:
      Label("Admin", systemImage: "exclamationmark.lock.fill")
    case .profile:
      Label("Profile", systemImage: "person.fill")
    }
  }
}
