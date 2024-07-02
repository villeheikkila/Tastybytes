import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ActivityTab: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    var body: some View {
        ActivityScreen()
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("friends.navigationTitle", systemImage: "person.2", open: .screen(.currentUserFriends))
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .customBadge(notificationEnvironmentModel.unreadFriendRequestCount)
        }
        ToolbarItem(placement: .principal) {}
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.navigationTitle", systemImage: "gear", open: .screen( .settings))
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }
}
