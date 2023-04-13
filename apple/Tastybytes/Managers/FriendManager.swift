import SwiftUI

@MainActor
class FriendManager: ObservableObject {
  private let logger = getLogger(category: "FriendsScreen")
  let client: Client
  @Published var friends = [Friend]()

  var acceptedFriends: [Profile] {
    friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: profile.id) }
  }

  var blockedUsers: [Friend] {
    friends.filter { $0.status == .blocked }
  }

  var acceptedOrPendingFriends: [Friend] {
    friends.filter { $0.status != .blocked }
  }

  let profile: Profile

  init(_ client: Client, profile: Profile) {
    self.client = client
    self.profile = profile
  }

  func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) async {
    switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
    case let .success(newFriend):
      withAnimation {
        self.friends.append(newFriend)
      }
      onSuccess()
    case let .failure(error):
      logger.warning("failed add new friend '\(receiver)': \(error.localizedDescription)")
    }
  }

  func updateFriendRequest(friend: Friend, newStatus: Friend.Status) async {
    let friendUpdate = Friend.UpdateRequest(
      sender: friend.sender,
      receiver: friend.receiver,
      status: newStatus
    )

    switch await client.friend.update(id: friend.id, friendUpdate: friendUpdate) {
    case let .success(updatedFriend):
      withAnimation {
        self.friends.replace(friend, with: updatedFriend)
      }
    case let .failure(error):
      logger
        .warning(
          "failed to update friend request: \(error.localizedDescription)"
        )
    }
  }

  func removeFriendRequest(_ friend: Friend) async {
    switch await client.friend.delete(id: friend.id) {
    case .success:
      withAnimation {
        self.friends.remove(object: friend)
      }
    case let .failure(error):
      logger.warning("failed to remove friend request '\(friend.id)': \(error.localizedDescription)")
    }
  }

  func isFriend(_ friend: Profile) -> Bool {
    friends.contains(where: { $0.getFriend(userId: profile.id).id == friend.id })
  }

  func loadFriends() async {
    switch await client.friend.getByUserId(
      userId: profile.id,
      status: .none
    ) {
    case let .success(friends):
      self.friends = friends
    case let .failure(error):
      logger.error("failed to load friends for current user: \(error.localizedDescription)")
    }
  }

  func unblockUser(_ friend: Friend) async {
    switch await client.friend.delete(id: friend.id) {
    case .success:
      withAnimation {
        self.friends.remove(object: friend)
      }
    case let .failure(error):
      logger.error("failed to unblock user \(friend.id): \(error.localizedDescription)")
    }
  }

  func blockUser(user: Profile, onSuccess: @escaping () -> Void) async {
    if let friend = friends.first(where: { $0.getFriend(userId: profile.id) == user }) {
      await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
    } else {
      switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
      case let .success(blockedUser):
        withAnimation {
          self.friends.append(blockedUser)
        }
        onSuccess()
      case let .failure(error):
        logger.error("failed to block user \(user.id): \(error.localizedDescription)")
      }
    }
  }
}
