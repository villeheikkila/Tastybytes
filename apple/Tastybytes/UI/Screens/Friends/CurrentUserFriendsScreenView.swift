import SwiftUI

struct CurrentUserFriendsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var noficationManager: NotificationManager
  @State private var friendToBeRemoved: Friend? {
    didSet {
      showRemoveFriendConfirmation = true
    }
  }

  @State private var showRemoveFriendConfirmation = false
  @State private var showUserSearchSheet = false

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
                  .onTapGesture { Task {
                    await friendManager.updateFriendRequest(friend: friend, newStatus: .accepted)
                  }
                  }
              }
            }
          }
        }
        .swipeActions {
          Group {
            if friend.isPending(userId: profileManager.getProfile().id) {
              ProgressButton(
                "Accept friend request",
                systemImage: "person.badge.plus",
                action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .accepted) }
              )
              .tint(.green)
            }
            Button("Delete", systemImage: "person.fill.xmark", role: .destructive, action: { friendToBeRemoved = friend })
            ProgressButton(
              "Block",
              systemImage: "person.2.slash",
              action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }
            )
          }.imageScale(.large)
        }
        .contextMenu {
          Button("Delete", systemImage: "person.fill.xmark", role: .destructive, action: { friendToBeRemoved = friend })
          ProgressButton(
            "Block",
            systemImage: "person.2.slash",
            action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }
          )
        }
      }
    }
    .navigationTitle("Friends (\(friendManager.friends.count))")
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await feedbackManager.wrapWithHaptics {
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
      ProgressButton(
        "Remove \(presenting.getFriend(userId: profileManager.getId()).preferredName) from friends",
        role: .destructive,
        action: {
          await friendManager.removeFriendRequest(presenting)
        }
      )
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouterLink(
        "Show name tag or send friend request by QR code",
        systemImage: "qrcode",
        sheet: .nameTag(onSuccess: { profileId in
          Task {
            await friendManager.sendFriendRequest(receiver: profileId, onSuccess: {
              feedbackManager.trigger(.notification(.success))
              feedbackManager.toggle(.success("Friend Request Sent!"))
            })
          }
        })
      )
      .labelStyle(.iconOnly)
      .imageScale(.large)

      RouterLink("Add friend", systemImage: "plus", sheet: .userSheet(mode: .add, onSubmit: {
        feedbackManager.toggle(.success("Friend Request Sent!"))
      }))
      .labelStyle(.iconOnly)
      .imageScale(.large)
    }
  }
}
