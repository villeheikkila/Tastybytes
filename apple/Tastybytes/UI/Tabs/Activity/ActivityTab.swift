import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTab: View {
  let client: Client
  @State private var scrollToTop: Int = 0
  @Binding private var resetNavigationOnTab: Tab?
  @EnvironmentObject private var notificationManager: NotificationManager

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    RouterWrapper(client) { router in
      CheckInListView(
        client,
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
