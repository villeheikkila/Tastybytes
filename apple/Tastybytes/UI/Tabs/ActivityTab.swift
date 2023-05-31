import SwiftUI

struct ActivityTab: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?
  @Binding var selectedTab: Tab

  var body: some View {
    RouterWrapper(tab: .activity) { router in
      ActivityScreen(scrollToTop: $scrollToTop, navigateToDiscoverTab: {
        selectedTab = .discover
      })
      .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
        if tab == .activity {
          if router.path.isEmpty {
            scrollToTop += 1
          } else {
            router.reset()
          }
          resetNavigationOnTab = nil
        }
      }
      .toolbar {
        toolbarContent
      }
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      RouterLink("Friends page", systemImage: "person.2", screen: .currentUserFriends)
        .labelStyle(.iconOnly)
        .imageScale(.large)
        .customBadge(notificationManager.getUnreadFriendRequestCount())
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouterLink("Settings page", systemImage: "gear", screen: .settings)
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }
  }
}
