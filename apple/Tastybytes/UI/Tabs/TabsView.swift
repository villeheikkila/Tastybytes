import SwiftUI

struct TabsView: View {
  let client: Client
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var friendManager: FriendManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  init(_ client: Client, profile: Profile) {
    self.client = client
    _friendManager = StateObject(wrappedValue: FriendManager(client, profile: profile))
  }

  private var tabs: [Tab] {
    [.activity, .search, .notifications, .profile]
  }

  private func shownTabs(profile: Profile.Extended) -> [Tab] {
    if profile.roles.contains(where: { $0.name == "admin" }) {
      return [.activity, .search, .notifications, .admin, .profile]
    } else {
      return [.activity, .search, .notifications, .profile]
    }
  }

  var body: some View {
    TabView(selection: .init(get: {
      selection
    }, set: { newTab in
      hapticManager.trigger(.selection)
      if newTab == selection {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          resetNavigationOnTab = selection
        }
      } else {
        selection = newTab
      }
    })) {
      ForEach(shownTabs(profile: profileManager.get())) { tab in
        tab.view(client, $resetNavigationOnTab)
          .tabItem {
            tab.label
          }
          .tag(tab)
          .badge(getBadgeByTab(tab))
      }
    }.task {
      await friendManager.loadFriends()
    }.environmentObject(friendManager)
  }

  private func getBadgeByTab(_ tab: Tab) -> Int {
    switch tab {
    case .notifications:
      return notificationManager.getUnreadCount()
    default:
      return 0
    }
  }
}

enum Tab: Int, Identifiable, Hashable {
  case activity, search, notifications, admin, profile

  var id: Int {
    rawValue
  }

  @ViewBuilder
  @MainActor
  func view(_ client: Client, _ resetNavigationOnTab: Binding<Tab?>) -> some View {
    switch self {
    case .activity:
      ActivityTab(client, resetNavigationOnTab: resetNavigationOnTab)
    case .search:
      DiscoverTab(client, resetNavigationOnTab: resetNavigationOnTab)
    case .notifications:
      NotificationTab(client, resetNavigationOnTab: resetNavigationOnTab)
    case .admin:
      AdminTab(client, resetNavigationOnTab: resetNavigationOnTab)
    case .profile:
      ProfileTab(client, resetNavigationOnTab: resetNavigationOnTab)
    }
  }

  @ViewBuilder
  var label: some View {
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
