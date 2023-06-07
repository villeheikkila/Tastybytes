import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @AppStorage(.selectedTab) private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  private let switchTabGestureRangeDistance: Double = 50

  private var shownTabs: [Tab] {
    if profileManager.hasRole(.admin) {
      return [.activity, .discover, .notifications, .admin, .profile]
    } else {
      return [.activity, .discover, .notifications, .profile]
    }
  }

  var switchTabGesture: some Gesture {
    DragGesture(minimumDistance: switchTabGestureRangeDistance)
      .onEnded { value in
        if value.translation.width < -switchTabGestureRangeDistance,
           value.translation.width > -(3 * switchTabGestureRangeDistance), selection.rawValue < shownTabs.count - 1
        {
          if let tab = Tab(rawValue: selection.rawValue + 1) {
            feedbackManager.trigger(.selection)
            selection = tab
          }
        } else if value.translation.width > switchTabGestureRangeDistance,
                  value.translation.width < 3 * switchTabGestureRangeDistance, selection.rawValue > 0
        {
          if let tab = Tab(rawValue: selection.rawValue - 1) {
            feedbackManager.trigger(.selection)
            selection = tab
          }
        }
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
        tab.view(selectedTab: $selection, $resetNavigationOnTab)
          .tabItem {
            tab.label
          }
          .tag(tab)
          .badge(getBadgeByTab(tab))
      }
    }
    .simultaneousGesture(switchTabGesture)
    .onOpenURL { url in
      if let tab = url.tab {
        selection = tab
      }
    }
  }

  private func getBadgeByTab(_ tab: Tab) -> Int {
    switch tab {
    case .notifications:
      return notificationManager.unreadCount
    default:
      return 0
    }
  }
}
