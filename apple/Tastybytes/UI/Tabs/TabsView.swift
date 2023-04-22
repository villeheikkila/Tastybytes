import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.orientation) private var orientation
  @State private var selection = Tab.activity
  @State private var resetNavigationOnTab: Tab?

  private var shownTabs: [Tab] {
    if profileManager.hasRole(.admin) {
      return [.activity, .search, .notifications, .admin, .profile]
    } else {
      return [.activity, .search, .notifications, .profile]
    }
  }

  var body: some View {
    Group {
      if isPadOrMac(), [.unknown, .landscapeLeft, .landscapeRight].contains(orientation) {
        sideBarView
      } else {
        tabView
      }
    }
  }

  @ViewBuilder private var tabView: some View {
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
  }

  var sideBarView: some View {
    NavigationSplitView {
      List {
        ForEach(shownTabs) { tab in
          Button(action: { selection = tab }, label: {
            tab.label
          })
        }
      }
    } detail: {
      selection.view($resetNavigationOnTab)
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
