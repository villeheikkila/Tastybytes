import SwiftUI

struct FriendsScreen: View {
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
      ForEach(viewModel.friends) { friend in
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
                  Label("Remove friend request", systemImage: "person.fill.xmark")
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                      viewModel.friendToBeRemoved = friend
                    }
                  Label("Accept friend request", systemImage: "person.badge.plus")
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                      viewModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                    }
                }
              }
            }
          }
          .swipeActions {
            if friend.isPending(userId: profileManager.getProfile().id) {
              Button(action: { viewModel.updateFriendRequest(friend: friend, newStatus: .accepted) }, label: {
                Label("Accept friend request", systemImage: "person.badge.plus")
                  .imageScale(.large)
              }).tint(.green)
            }
            Button(role: .destructive, action: { viewModel.friendToBeRemoved = friend }, label: {
              Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
            })
            Button(action: { viewModel.updateFriendRequest(friend: friend, newStatus: .blocked) }, label: {
              Label("Block", systemImage: "person.2.slash").imageScale(.large)
            })
          }
          .contextMenu {
            Button(role: .destructive, action: { viewModel.friendToBeRemoved = friend }, label: {
              Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
            })
            Button(action: { viewModel.updateFriendRequest(friend: friend, newStatus: .blocked) }, label: {
              Label("Block", systemImage: "person.2.slash").imageScale(.large)
            })
          }
        } else {
          FriendListItemView(profile: friend.getFriend(userId: viewModel.profile.id)) {}
        }
      }
      .navigationTitle("Friends (\(viewModel.friends.count))")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadFriends(currentUser: profileManager.getProfile())
      }
    }
    .task {
      await viewModel.loadFriends(currentUser: profileManager.getProfile())
      if viewModel.profile == profileManager.getProfile() {
        noficationManager.markAllFriendRequestsAsRead()
      }
    }
    .toolbar {
      toolbarContent
    }
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheet(viewModel.client, actions: { profile in
          HStack {
            if !viewModel.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: {
                hapticManager.trigger(.impact(intensity: .low))
                viewModel.sendFriendRequest(receiver: profile.id, onSuccess: {
                  toastManager.toggle(.success("Friend Request Sent!"))
                })
              }, label: {
                Label("Add as a friend", systemImage: "person.badge.plus")
                  .labelStyle(.iconOnly)
                  .imageScale(.large)
              })
            }
          }
          .errorAlert(error: $viewModel.modalError)
        })
      }
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $viewModel.showProfileQrCode) {
      NavigationStack {
        NameTagSheet(onSuccess: { profileId in
          viewModel.sendFriendRequest(receiver: profileId, onSuccess: {
            viewModel.showProfileQrCode = false
            hapticManager.trigger(.notification(.success))
            toastManager.toggle(.success("Friend Request Sent!"))
            Task {
              await viewModel.loadFriends(currentUser: profileManager.getProfile())
            }
          })
        })
      }
      .presentationDetents([.medium])
    }
    .errorAlert(error: $viewModel.error)
    .confirmationDialog("Delete Friend Confirmation",
                        isPresented: $viewModel.showRemoveFriendConfirmation,
                        presenting: viewModel.friendToBeRemoved)
    { presenting in
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

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if viewModel.profile == profileManager.getProfile() {
        Button(action: { viewModel.showProfileQrCode.toggle() }, label: {
          Label("Show name tag or send friend request by QR code", systemImage: "qrcode")
            .labelStyle(.iconOnly)
            .imageScale(.large)
        })

        Button(action: { viewModel.showUserSearchSheet.toggle() }, label: {
          Label("Add friend", systemImage: "plus")
            .labelStyle(.iconOnly)
            .imageScale(.large)
        })
      }
    }
  }
}
