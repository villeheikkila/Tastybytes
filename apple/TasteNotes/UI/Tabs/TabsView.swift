import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var selection = Tab.activity
  @State private var resetNavigationStackOnTab: Tab?

  private var tabs: [Tab] {
    [.activity, .search, .notifications, .profile]
  }

  private func getBadgeByTab(_ tab: Tab) -> Int {
    switch tab {
    case .notifications:
      return notificationManager.getUnreadCount()
    default:
      return 0
    }
  }

  var body: some View {
    TabView(selection: .init(get: {
      selection
    }, set: { newTab in
      if newTab == selection {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          resetNavigationStackOnTab = selection
        }
      }
      selection = newTab
    })) {
      ForEach(tabs) { tab in
        tab.view($resetNavigationStackOnTab)
          .tabItem {
            tab.label
          }
          .tag(tab)
          .badge(getBadgeByTab(tab))
      }
    }
  }
}

enum Tab: Int, Identifiable, Hashable {
  case activity, search, notifications, profile

  var id: Int {
    rawValue
  }

  @ViewBuilder
  func view(_ resetNavigationStackOnTab: Binding<Tab?>) -> some View {
    switch self {
    case .activity:
      ActivityTabView(resetNavigationStackOnTab: resetNavigationStackOnTab)
    case .search:
      SearchTabView(resetNavigationStackOnTab: resetNavigationStackOnTab)
    case .notifications:
      NotificationTabView(resetNavigationStackOnTab: resetNavigationStackOnTab)
    case .profile:
      ProfileTabView(resetNavigationStackOnTab: resetNavigationStackOnTab)
    }
  }

  @ViewBuilder
  var label: some View {
    switch self {
    case .activity:
      Label("Activity", systemImage: "list.star")
    case .search:
      Label("Search", systemImage: "magnifyingglass")
    case .notifications:
      Label("Notifications", systemImage: "bell")
    case .profile:
      Label("Profile", systemImage: "person.fill")
    }
  }
}
