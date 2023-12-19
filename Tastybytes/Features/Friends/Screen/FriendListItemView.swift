import Components
import Models
import SwiftUI

struct FriendListItemView<RootView: View>: View {
    @Environment(Router.self) private var router
    let profile: Profile
    let view: () -> RootView?

    init(
        profile: Profile,
        @ViewBuilder view: @escaping () -> RootView? = { nil }
    ) {
        self.view = view
        self.profile = profile
    }

    var body: some View {
        RouterLink(screen: .profile(profile)) {
            HStack {
                AvatarView(avatarUrl: profile.avatarUrl, size: 42, id: profile.id)
                Text(profile.preferredName)
                    .padding(.leading, 8)
                    .foregroundColor(.primary)
                if RootView.self == EmptyView.self {
                    Spacer()
                } else {
                    view()
                }
            }
        }
        .padding(.vertical, 3)
    }
}
