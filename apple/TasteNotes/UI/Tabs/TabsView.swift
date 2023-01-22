import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  private var tabs: [Tab] {
    [.activity, .search, .notifications, .profile]
  }

  var body: some View {
    TabView(selection: .init(get: {
      selection
    }, set: { newTab in
      if newTab == selection {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          resetNavigationOnTab = selection
        }
      }
      selection = newTab
    })) {
      ForEach(tabs) { tab in
        tab.view($resetNavigationOnTab)
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
  func view(_ resetNavigationOnTab: Binding<Tab?>) -> some View {
    switch self {
    case .activity:
      ActivityTabView(resetNavigationOnTab: resetNavigationOnTab)
    case .search:
      SearchTabView(resetNavigationOnTab: resetNavigationOnTab)
    case .notifications:
      NotificationTabView(resetNavigationOnTab: resetNavigationOnTab)
    case .profile:
      ProfileTabView(resetNavigationOnTab: resetNavigationOnTab)
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
