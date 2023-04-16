import SwiftUI

struct DiscoverTab: View {
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      SearchListView(scrollToTop: $scrollToTop)
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
