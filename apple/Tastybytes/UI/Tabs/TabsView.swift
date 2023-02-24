import SwiftUI

struct TabsView: View {
  let client: Client
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  init(_ client: Client) {
    self.client = client
  }

  private var tabs: [Tab] {
    [.activity, .search, .notifications, .profile]
  }

  var body: some View {
    TabView(selection: .init(get: {
      selection
    }, set: { newTab in
      hapticManager.trigger(of: .selection)
      if newTab == selection {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          resetNavigationOnTab = selection
        }
      } else {
        selection = newTab
      }
    })) {
      ForEach(tabs) { tab in
        tab.view(client, $resetNavigationOnTab)
          .tabItem {
            tab.label
          }
          .tag(tab)
          .badge(getBadgeByTab(tab))
      }
    }
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
  case activity, search, notifications, profile

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
    case .profile:
      Label("Profile", systemImage: "person.fill")
    }
  }
}
