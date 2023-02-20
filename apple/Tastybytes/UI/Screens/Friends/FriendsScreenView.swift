import SwiftUI

struct FriendsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var noficationManager: NotificationManager

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    List {
      ForEach(viewModel.friends, id: \.self) { friend in
        if viewModel.profile == profileManager.getProfile() {
          FriendListItemView(profile: friend.getFriend(userId: viewModel.profile.id)) {
            HStack {
              if friend.status == Friend.Status.pending {
                Text("(\(friend.status.rawValue.capitalized))")
                  .font(.footnote)
                  .foregroundColor(.primary)
              }
              Spacer()
              if friend.isPending(userId: profileManager.getProfile().id) {
                HStack(alignment: .center) {
                  Image(systemName: "person.fill.xmark")
                    .imageScale(.large)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                      viewModel.friendToBeRemoved = friend
                    }
                  Image(systemName: "person.badge.plus")
                    .imageScale(.large)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                      viewModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                    }
                }
              }
            }
          }
          .contextMenu {
            Button(action: {
              viewModel.friendToBeRemoved = friend
            }) {
              Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
            }
            Button(action: {
              viewModel.updateFriendRequest(friend: friend, newStatus: .blocked)
            }) {
              Label("Block", systemImage: "person.2.slash").imageScale(.large)
            }
          }
        } else {
          FriendListItemView(profile: friend.getFriend(userId: viewModel.profile.id)) {}
        }
      }
      .navigationTitle("Friends (\(viewModel.friends.count))")
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
              Button(action: {
                hapticManager.trigger(of: .impact(intensity: .low))
                viewModel.sendFriendRequest(receiver: profile.id, onSuccess: {
                  toastManager.toggle(.success("Friend Request Sent!"))
                })
              }) {
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
