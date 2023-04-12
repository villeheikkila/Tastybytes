import SwiftUI

struct DiscoverTab: View {
  @Binding private var resetNavigationOnTab: Tab?
  @State private var scrollToTop: Int = 0

  let client: Client

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    RouterWrapper(client) { router in
      SearchListView(client, scrollToTop: $scrollToTop)
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
    }
  }
}
