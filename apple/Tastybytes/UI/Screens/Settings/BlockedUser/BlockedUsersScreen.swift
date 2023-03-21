import SwiftUI

struct BlockedUsersScreen: View {
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var toastManager: ToastManager
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
    .sheet(isPresented: $showUserSearchSheet) {
      NavigationStack {
        UserSheet(client, actions: { profile in
          HStack {
            if !friendManager.blockedUsers.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: { friendManager.blockUser(user: profile, onSuccess: {
                toastManager.toggle(.success("User blocked"))
                showUserSearchSheet = false
              }, onFailure: { error in
                toastManager.toggle(.error(error))
              }) }, label: {
                Label("Block", systemImage: "person.fill.xmark")
                  .imageScale(.large)
              })
            }
          }
        })
      }
      .presentationDetents([.medium])
    }
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await friendManager.loadFriends()
    }
  }

  private var blockUser: some View {
    HStack {
      Button(action: { showUserSearchSheet.toggle() }, label: {
        Label("Show block user sheet", systemImage: "plus")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      })
    }
  }
}
