import SwiftUI

struct CurrentUserFriendsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var noficationManager: NotificationManager
  @EnvironmentObject private var router: Router
  @State private var friendToBeRemoved: Friend? {
    didSet {
      showRemoveFriendConfirmation = true
    }
  }

  @State private var showRemoveFriendConfirmation = false
  @State private var showUserSearchSheet = false

  let client: Client
  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    List {
      ForEach(friendManager.acceptedOrPendingFriends) { friend in
        FriendListItemView(profile: friend.getFriend(userId: friendManager.profile.id)) {
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
                    friendToBeRemoved = friend
                  }
                Label("Accept friend request", systemImage: "person.badge.plus")
                  .imageScale(.large)
                  .labelStyle(.iconOnly)
                  .accessibilityAddTraits(.isButton)
                  .onTapGesture {
                    friendManager.updateFriendRequest(friend: friend, newStatus: .accepted)
                  }
              }
            }
          }
        }
        .swipeActions {
          if friend.isPending(userId: profileManager.getProfile().id) {
            Button(action: { friendManager.updateFriendRequest(friend: friend, newStatus: .accepted) }, label: {
              Label("Accept friend request", systemImage: "person.badge.plus").imageScale(.large)
            }).tint(.green)
          }
          Button(role: .destructive, action: { friendToBeRemoved = friend }, label: {
            Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
          })
          Button(action: { friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }, label: {
            Label("Block", systemImage: "person.2.slash").imageScale(.large)
          })
        }
        .contextMenu {
          Button(role: .destructive, action: { friendToBeRemoved = friend }, label: {
            Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
          })
          Button(action: { friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }, label: {
            Label("Block", systemImage: "person.2.slash").imageScale(.large)
          })
        }
      }
    }
    .navigationTitle("Friends (\(friendManager.friends.count))")
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await friendManager.loadFriends()
      }
    }
    .task {
      await noficationManager.markAllFriendRequestsAsRead()
    }
    .toolbar {
      toolbarContent
    }
    .confirmationDialog(
      "Remove user from your friends, you will no longer be able to see each other's check-ins on your activity feed nor be able to tag each other on check-ins",
      isPresented: $showRemoveFriendConfirmation,
      titleVisibility: .visible,
      presenting: friendToBeRemoved
    ) { presenting in
      Button(
        "Remove \(presenting.getFriend(userId: profileManager.getId()).preferredName) from friends",
        role: .destructive,
        action: {
          withAnimation {
            friendManager.removeFriendRequest(presenting)
          }
        }
      )
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: { router.navigate(sheet: .nameTag(onSuccess: { profileId in
        friendManager.sendFriendRequest(receiver: profileId, onSuccess: {
          hapticManager.trigger(.notification(.success))
          toastManager.toggle(.success("Friend Request Sent!"))
          Task {
            await friendManager.loadFriends()
          }
        })
      })) }, label: {
        Label("Show name tag or send friend request by QR code", systemImage: "qrcode")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      })

      Button(action: { router.navigate(sheet: .userSheet(mode: .add, onSubmit: {
        toastManager.toggle(.success("Friend Request Sent!"))
      })) }, label: {
        Label("Add friend", systemImage: "plus")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      })
    }
  }
}
