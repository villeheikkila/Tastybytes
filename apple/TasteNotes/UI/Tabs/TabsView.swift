import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var selection = Tab.activity

  var body: some View {
    TabView(selection: $selection) {
      activityScreen
      searchScreen
      notificationScreen
      profileScreen
    }
  }

  var activityScreen: some View {
    ActivityTabView(profile: profileManager.getProfile())
      .tabItem {
        Image(systemName: "list.star")
        Text("Activity")
      }
      .tag(Tab.activity)
  }

  var searchScreen: some View {
    SearchTabView()
      .tabItem {
        Image(systemName: "magnifyingglass")
        Text("Search")
      }
      .tag(Tab.search)
  }

  var notificationScreen: some View {
    NotificationTabView()
      .tabItem {
        Image(systemName: "bell")
        Text("Notifications")
      }
      .badge(notificationManager
        .notifications
        .filter { $0.seenAt == nil }
        .count)
      .tag(Tab.notifications)
  }

  var profileScreen: some View {
    ProfileTabView(profile: profileManager.getProfile())
      .tabItem {
        Image(systemName: "person.fill")
        Text("Profile")
      }
      .tag(Tab.profile)
  }
}

extension TabsView {
  enum Tab: Int, Equatable {
    case activity = 1
    case search = 2
    case notifications = 3
    case profile = 4

    var title: String {
      switch self {
      case .activity:
        return "Activity"
      case .search:
        return "Search"
      case .notifications:
        return "Notifications"
      case .profile:
        return ""
      }
    }
  }
}
