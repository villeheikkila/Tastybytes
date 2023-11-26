import EnvironmentModels
import Models
import SwiftUI

struct ActivityTab: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @State private var scrollToTop: Int = 0
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        RouterWrapper(tab: .activity) { router in
            ActivityScreen(scrollToTop: $scrollToTop)
                .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                    if tab == .activity {
                        if router.path.isEmpty {
                            scrollToTop += 1
                        } else {
                            router.reset()
                        }
                        resetNavigationOnTab = nil
                    }
                }
                .toolbar {
                    toolbarContent
                }
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
