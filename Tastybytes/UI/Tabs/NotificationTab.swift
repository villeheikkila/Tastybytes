import EnvironmentModels
import Models
import SwiftUI

struct NotificationTab: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(Router.self) private var router
    @State private var scrollToTop: Int = 0
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        NotificationScreen(scrollToTop: $scrollToTop)
            .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
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
