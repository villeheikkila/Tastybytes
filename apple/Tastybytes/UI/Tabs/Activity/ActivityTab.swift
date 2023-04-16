import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTab: View {
  @State private var scrollToTop: Int = 0
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var client: AppClient
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      CheckInListView(
        fetcher: .activityFeed,
        scrollToTop: $scrollToTop,
        onRefresh: {},
        header: {}
      )
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
      .navigationTitle("Activity")
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
