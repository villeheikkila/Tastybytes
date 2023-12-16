import EnvironmentModels
import Models
import SwiftUI

struct ActivityTab: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @State private var scrollToTop: Int = 0

    var body: some View {
        ActivityScreen(scrollToTop: $scrollToTop)
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if tab == .activity {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("Friends page", systemImage: "person.2", screen: .currentUserFriends)
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .customBadge(notificationEnvironmentModel.getUnreadFriendRequestCount())
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("Settings page", systemImage: "gear", screen: .settings)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }
}
