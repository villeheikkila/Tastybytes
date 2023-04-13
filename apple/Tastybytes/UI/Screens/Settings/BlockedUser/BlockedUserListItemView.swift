import SwiftUI

struct BlockedUserListItemView: View {
  let profile: Profile
  let onUnblockUser: () async -> Void

  var body: some View {
    HStack(alignment: .center) {
      AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
      VStack {
        HStack {
          Text(profile.preferredName)
          Spacer()
          ProgressButton("Unblock", systemImage: "hand.raised.slash.fill", action: { await onUnblockUser() })
        }
      }
    }
  }
}
