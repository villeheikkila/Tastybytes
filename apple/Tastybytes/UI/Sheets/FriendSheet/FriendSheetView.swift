import SwiftUI

struct FriendSheetView: View {
  @Binding private var taggedFriends: [Profile]
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  init(_ client: Client, taggedFriends: Binding<[Profile]>) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _taggedFriends = taggedFriends
  }

  var body: some View {
    List(viewModel.friends, id: \.self) { friend in
      Button(action: {
        withAnimation {
          toggleFriend(friend: friend)
        }
      }) {
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
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Done").bold()
    })
    .task {
      viewModel.loadFriends(currentUserId: profileManager.getId())
    }
  }

  private func toggleFriend(friend: Profile) {
    if taggedFriends.contains(friend) {
      taggedFriends.remove(object: friend)
    } else {
      taggedFriends.append(friend)
    }
  }
}
