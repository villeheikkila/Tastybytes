import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct ActivityTabView: View {
  @StateObject private var router = Router()
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?
  @State private var resetView: Int = 0

  var body: some View {
    NavigationStack(path: $router.path) {
      CheckInListView(fetcher: .activityFeed, scrollToTop: $scrollToTop, resetView: $resetView) {}
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
            router.fetchAndNavigateTo(detailPage)
          }
        }
        .withRoutes()
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
