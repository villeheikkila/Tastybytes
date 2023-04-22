import SwiftUI

struct TabsView: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
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
        ForEach(shownTabs) { newTab in
          Button(action: {
            feedbackManager.trigger(.selection)
            if newTab == selection {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                resetNavigationOnTab = selection
              }
            } else {
              selection = newTab
            }
          }, label: {
            newTab.label
          })
        }
      }
    } content: {
      Text("HEi")
    } detail: {
      selection.view($resetNavigationOnTab)
    }.navigationSplitViewStyle(.balanced)
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
