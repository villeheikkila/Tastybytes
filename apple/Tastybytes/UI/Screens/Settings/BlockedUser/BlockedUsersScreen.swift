import SwiftUI

struct BlockedUsersScreen: View {
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var router: Router
  @State private var showUserSearchSheet = false

  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    List {
      if friendManager.blockedUsers.isEmpty {
        Text("You haven't blocked any users")
      }
      ForEach(friendManager.blockedUsers) { friend in
        BlockedUserListItemView(profile: friend.getFriend(userId: friendManager.profile.id), onUnblockUser: {
          friendManager.unblockUser(friend)
        })
      }
    }
    .navigationTitle("Blocked Users")
    .navigationBarItems(
      trailing: blockUser
    )
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await friendManager.loadFriends()
    }
  }

  private var blockUser: some View {
    HStack {
      Button(action: { router.navigate(sheet: .userSheet(mode: .block, onSubmit: {
        toastManager.toggle(.success("User blocked"))
      })) }, label: {
        Label("Show block user sheet", systemImage: "plus")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      })
    }
  }
}
