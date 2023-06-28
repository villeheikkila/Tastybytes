import SwiftUI

struct DiscoverTab: View {
    @State private var scrollToTop: Int = 0
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        RouterWrapper(tab: .discover) { router in
            DiscoverScreen(scrollToTop: $scrollToTop)
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
