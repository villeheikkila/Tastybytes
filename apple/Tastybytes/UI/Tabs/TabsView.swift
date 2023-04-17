import SwiftUI

struct TabsView: View {
  let repository: Repository
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var friendManager: FriendManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  init(_ repository: Repository, profile: Profile) {
    self.repository = repository
    _friendManager = StateObject(wrappedValue: FriendManager(repository: repository, profile: profile))
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
      feedbackManager.trigger(.selection)
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
    }
    .environmentObject(friendManager)
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
