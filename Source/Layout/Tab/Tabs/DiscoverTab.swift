import Models
import SwiftUI

@MainActor
struct DiscoverTab: View {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @State private var scrollToTop: Int = 0

    var body: some View {
        DiscoverScreen(scrollToTop: $scrollToTop)
            .scrollToTopBackToRootOnTab(.discover, scrollToTop: $scrollToTop)
    }
}
