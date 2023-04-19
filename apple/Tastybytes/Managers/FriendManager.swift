import SwiftUI

@MainActor
final class FriendManager: ObservableObject {
  private let logger = getLogger(category: "FriendsScreen")
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
  let repository: Repository
  let feedbackManager: FeedbackManager

  init(repository: Repository, profile: Profile, feedbackManager: FeedbackManager) {
    self.repository = repository
    self.profile = profile
    self.feedbackManager = feedbackManager
  }

  func sendFriendRequest(receiver: UUID, onSuccess: (() -> Void)? = nil) async {
    switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
    case let .success(newFriend):
      withAnimation {
        self.friends.append(newFriend)
      }
      feedbackManager.toggle(.success("Friend Request Sent!"))
      if let onSuccess {
        onSuccess()
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed add new friend '\(receiver)': \(error.localizedDescription)")
    }
  }

  func updateFriendRequest(friend: Friend, newStatus: Friend.Status) async {
    let friendUpdate = Friend.UpdateRequest(
      sender: friend.sender,
      receiver: friend.receiver,
      status: newStatus
    )

    switch await repository.friend.update(id: friend.id, friendUpdate: friendUpdate) {
    case let .success(updatedFriend):
      withAnimation {
        self.friends.replace(friend, with: updatedFriend)
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger
        .warning(
          "failed to update friend request: \(error.localizedDescription)"
        )
    }
  }

  func removeFriendRequest(_ friend: Friend) async {
    switch await repository.friend.delete(id: friend.id) {
    case .success:
      withAnimation {
        self.friends.remove(object: friend)
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to remove friend request '\(friend.id)': \(error.localizedDescription)")
    }
  }

  func isFriend(_ friend: Profile) -> Bool {
    friends.contains(where: { $0.getFriend(userId: profile.id).id == friend.id })
  }

  func loadFriends() async {
    switch await repository.friend.getByUserId(
      userId: profile.id,
      status: .none
    ) {
    case let .success(friends):
      self.friends = friends
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load friends for current user: \(error.localizedDescription)")
    }
  }

  func unblockUser(_ friend: Friend) async {
    switch await repository.friend.delete(id: friend.id) {
    case .success:
      withAnimation {
        self.friends.remove(object: friend)
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to unblock user \(friend.id): \(error.localizedDescription)")
    }
  }

  func blockUser(user: Profile, onSuccess: @escaping () -> Void) async {
    if let friend = friends.first(where: { $0.getFriend(userId: profile.id) == user }) {
      await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
    } else {
      switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
      case let .success(blockedUser):
        withAnimation {
          self.friends.append(blockedUser)
        }
        onSuccess()
      case let .failure(error):
        feedbackManager.toggle(.error(.unexpected))
        logger.error("failed to block user \(user.id): \(error.localizedDescription)")
      }
    }
  }
}
