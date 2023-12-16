import Models
import SwiftUI

struct DiscoverTab: View {
    @Environment(Router.self) private var router
    @State private var scrollToTop: Int = 0
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        DiscoverScreen(scrollToTop: $scrollToTop)
            .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                if tab == .discover {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    }
                } else {
                    router.reset()
                }
            }
    }
}
