import SwiftUI

struct TabsView: View {
  let repository: Repository
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var friendManager: FriendManager
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  init(_ repository: Repository, profile: Profile, feedbackManager: FeedbackManager) {
    self.repository = repository
    _friendManager =
      StateObject(wrappedValue: FriendManager(repository: repository, profile: profile, feedbackManager: feedbackManager))
  }

  private var shownTabs: [Tab] {
    if profileManager.hasRole(.admin) {
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
      ForEach(shownTabs) { tab in
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
