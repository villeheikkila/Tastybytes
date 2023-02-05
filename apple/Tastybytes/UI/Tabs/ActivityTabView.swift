import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTabView: View {
  let client: Client
  @StateObject private var router = Router()
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?
  @State private var resetView: Int = 0

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
        resetView: $resetView,
        onRefresh: {}
      ) {}
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
        .onAppear {
          router.reset()
        }
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage)
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
        Image(systemName: "person.2").imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Image(systemName: "gear").imageScale(.large)
      }
    }
  }
}
