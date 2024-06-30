import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendListItemView<RootView: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
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
                Avatar(profile: profile)
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
