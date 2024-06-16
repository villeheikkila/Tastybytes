import EnvironmentModels
import Models
import Repositories
import SwiftUI

@MainActor
struct ActivityTab: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @Environment(Repository.self) private var repository
    @State private var scrollToTop: Int = 0

    var body: some View {
        ActivityScreen(scrollToTop: $scrollToTop)
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if tab == .activity {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("friends.navigationTitle", systemImage: "person.2", screen: .currentUserFriends)
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .customBadge(notificationEnvironmentModel.unreadFriendRequestCount)
        }
        ToolbarItem(placement: .principal) {}
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.navigationTitle", systemImage: "gear", screen: .settings)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }
}
