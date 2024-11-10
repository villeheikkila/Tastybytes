import Components
import SwiftUI

struct FriendRouterLinkWithUnreadCountBadgeView: View {
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        RouterLink("friends.navigationTitle", systemImage: "person.2", open: .screen(.currentUserFriends))
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .customBadge(profileModel.unreadFriendRequestCount)
    }
}
