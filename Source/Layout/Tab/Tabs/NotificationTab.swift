import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct NotificationTab: View {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @State private var scrollToTop: Int = 0

    var body: some View {
        NotificationScreen(scrollToTop: $scrollToTop)
            .scrollToTopBackToRootOnTab(.notifications, scrollToTop: $scrollToTop)
    }
}
