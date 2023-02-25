import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTab: View {
  let client: Client
  @StateObject private var router = Router()
  @State private var scrollToTop: Int = 0
  @Binding private var resetNavigationOnTab: Tab?

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
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
      .onOpenURL { url in
        if let detailPage = url.detailPage {
          router.fetchAndNavigateTo(client, detailPage, resetStack: true)
        }
      }
      .withRoutes(client)
    }
    .environmentObject(router)
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      NavigationLink(value: Route.currentUserFriends) {
        Label("Friends page", systemImage: "person.2")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Label("Settings page", systemImage: "gear")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      }
    }
  }
}
