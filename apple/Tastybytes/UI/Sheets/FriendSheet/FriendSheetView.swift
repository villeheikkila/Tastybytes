import SwiftUI

struct FriendSheetView: View {
  @Binding var taggedFriends: [Profile]
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List(profileManager.friends, id: \.self) { friend in
      Button(action: { toggleFriend(friend: friend) }) {
        AvatarView(avatarUrl: friend.avatarUrl, size: 32, id: friend.id)
        Text(friend.preferredName)
        Spacer()
        if taggedFriends.contains(friend) {
          Image(systemName: "checkmark")
        }
      }
    }
    .buttonStyle(.plain)
    .navigationTitle("Friends")
    .navigationBarItems(trailing: Button(action: { dismiss() }) {
      Text("Done").bold()
    })
  }

  private func toggleFriend(friend: Profile) {
    withAnimation {
      if taggedFriends.contains(friend) {
        taggedFriends.remove(object: friend)
      } else {
        taggedFriends.append(friend)
      }
    }
  }
}
