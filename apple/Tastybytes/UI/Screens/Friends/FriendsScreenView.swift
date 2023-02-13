import SwiftUI

struct FriendsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var noficationManager: NotificationManager

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    ScrollView {
      ForEach(viewModel.friends, id: \.self) { friend in
        if viewModel.profile == profileManager.getProfile() {
          FriendListItemView(friend: friend,
                             currentUser: profileManager.getProfile(),
                             onAccept: { _ in
                               viewModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                             },
                             onBlock: { _ in viewModel.updateFriendRequest(friend: friend, newStatus: .blocked) },
                             onDelete: { _ in
                               viewModel.friendToBeRemoved = friend
                             })
        } else {
          FriendListItemSimpleView(profile: friend.getFriend(userId: viewModel.profile.id))
        }
      }
      .navigationTitle("Friends")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      viewModel.loadFriends(currentUser: profileManager.getProfile())
    }
    .task {
      viewModel.loadFriends(currentUser: profileManager.getProfile())
      if viewModel.profile == profileManager.getProfile() {
        noficationManager.markAllFriendRequestsAsRead()
      }
    }
    .navigationBarItems(
      trailing: addFriendButton
    )
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheetView(viewModel.client, actions: { profile in
          HStack {
            if !viewModel.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: { viewModel.sendFriendRequest(receiver: profile.id, onSuccess: {
                toastManager.toggle(.success("Friend Request Sent!"))
              }) }) {
                Image(systemName: "person.badge.plus")
                  .imageScale(.large)
              }
            }
          }
          .errorAlert(error: $viewModel.modalError)
        })
      }
      .presentationDetents([.medium])
    }
    .errorAlert(error: $viewModel.error)
    .confirmationDialog("Delete Friend Confirmation",
                        isPresented: $viewModel.showRemoveFriendConfirmation,
                        presenting: viewModel.friendToBeRemoved) { presenting in
      Button(
        "Remove \(presenting.getFriend(userId: profileManager.getId()).preferredName) from friends",
        role: .destructive,
        action: {
          withAnimation {
            viewModel.removeFriendRequest(presenting)
          }
        }
      )
    }
  }

  private var addFriendButton: some View {
    HStack {
      if viewModel.profile == profileManager.getProfile() {
        Button(action: { viewModel.showUserSearchSheet.toggle() }) {
          Image(systemName: "plus").imageScale(.large)
        }
      }
    }
  }
}
