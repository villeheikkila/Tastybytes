import EnvironmentModels
import Models
import SwiftUI

struct NotificationTab: View {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @State private var scrollToTop: Int = 0

    var body: some View {
        NotificationScreen(scrollToTop: $scrollToTop)
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if tab == .notifications {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
    }
}
