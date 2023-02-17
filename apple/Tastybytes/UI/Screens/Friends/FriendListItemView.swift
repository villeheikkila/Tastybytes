import SwiftUI

struct FriendListItemView<RootView: View>: View {
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
    NavigationLink(value: Route.profile(profile)) {
      HStack(alignment: .center) {
        AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
        Text(profile.preferredName)
          .foregroundColor(.primary)
        if RootView.self == EmptyView.self {
          Spacer()
        } else {
          view()
        }
      }
    }
    .padding(.all, 10)
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    .padding([.leading, .trailing], 10)
  }
}
