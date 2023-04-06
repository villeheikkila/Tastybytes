import SwiftUI

struct DiscoverTab: View {
  @StateObject private var router = Router()
  @Binding private var resetNavigationOnTab: Tab?
  @State private var scrollToTop: Int = 0

  let client: Client

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      SearchListView(client, scrollToTop: $scrollToTop)
        .withRoutes(client)
        .withSheets(client, sheetRoute: $router.sheet)
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage, resetStack: true)
          }
        }
    }
    .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
      if tab == .search {
        if router.path.isEmpty {
          scrollToTop += 1
        }
      } else {
        router.reset()
      }
      resetNavigationOnTab = nil
    }
    .environmentObject(router)
  }
}
