import SwiftUI

struct FriendSheet: View {
  @Binding var taggedFriends: [Profile]
  @EnvironmentObject private var friendManager: FriendManager
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List(friendManager.acceptedFriends) { friend in
      Button(action: { toggleFriend(friend: friend) }, label: {
        AvatarView(avatarUrl: friend.avatarUrl, size: 32, id: friend.id)
        Text(friend.preferredName)
        Spacer()
        Label("Tag friend", systemImage: "checkmark")
          .labelStyle(.iconOnly)
          .opacity(taggedFriends.contains(friend) ? 1 : 0)
      })
    }
    .buttonStyle(.plain)
    .navigationTitle("Friends")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
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
