import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var selection = Tab.activity
  @State private var selectedTab: Tab = .activity
  @State private var backToRoot: Tab = .activity

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
      selectedTab
    }, set: { newTab in
      print(newTab)
      if newTab == selectedTab {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          backToRoot = selectedTab
        }
      }
      selectedTab = newTab
    })) {
      ForEach(tabs) { tab in
        tab.makeContentView(backToRoot: $backToRoot)
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
  func makeContentView(backToRoot: Binding<Tab>) -> some View {
    switch self {
    case .activity:
      ActivityTabView(backToRoot: backToRoot)
    case .search:
      SearchTabView(backToRoot: backToRoot)
    case .notifications:
      NotificationTabView(backToRoot: backToRoot)
    case .profile:
      ProfileTabView(backToRoot: backToRoot)
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
