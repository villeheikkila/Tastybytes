import Components

import Models
import SwiftUI

struct FriendListItemView<RootView: View>: View {
    let profile: Profile.Saved
    let view: () -> RootView?

    init(
        profile: Profile.Saved,
        @ViewBuilder view: @escaping () -> RootView? = { nil }
    ) {
        self.view = view
        self.profile = profile
    }

    var body: some View {
        RouterLink(open: .screen(.profile(profile))) {
            HStack {
                AvatarView(profile: profile)
                    .avatarSize(.extraLarge)
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
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            -viewDimensions.width
        }
    }
}
