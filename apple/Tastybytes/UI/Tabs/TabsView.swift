import SwiftUI

struct TabsView: View {
  let client: Client
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var appDataManager: AppDataManager
  @StateObject private var friendManager: FriendManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  init(_ client: Client, profile: Profile) {
    self.client = client
    _friendManager = StateObject(wrappedValue: FriendManager(client: client, profile: profile))
    _appDataManager = StateObject(wrappedValue: AppDataManager(client: client))
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
        tab.view($resetNavigationOnTab)
          .tabItem {
            tab.label
          }
          .tag(tab)
          .badge(getBadgeByTab(tab))
      }
    }
    .task {
      await friendManager.loadFriends()
      await appDataManager.initialize()
    }
    .environmentObject(friendManager)
    .environmentObject(appDataManager)
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
