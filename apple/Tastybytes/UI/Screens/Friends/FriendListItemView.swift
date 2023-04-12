import SwiftUI

struct FriendListItemView<RootView: View>: View {
  @EnvironmentObject private var router: Router
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
    HStack(alignment: .center) {
      RouterLink(screen: .profile(profile), asTapGesture: true) {
        HStack {
          AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
          Text(profile.preferredName)
            .foregroundColor(.primary)
        }
      }
      if RootView.self == EmptyView.self {
        Spacer()
      } else {
        view()
      }
    }
    .padding([.top, .bottom], 3)
  }
}
