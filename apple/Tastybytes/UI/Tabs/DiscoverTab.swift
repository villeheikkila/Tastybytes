import SwiftUI

struct DiscoverTab: View {
  @State private var scrollToTop: Int = 0
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper(tab: .discover) { router in
      DiscoverScreen(scrollToTop: $scrollToTop)
        .task {
          await splashScreenManager.dismiss()
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
          if tab == .discover {
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
