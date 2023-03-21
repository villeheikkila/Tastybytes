import SwiftUI

extension FriendsScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FriendsScreen")
    let client: Client
    @Published var searchText: String = ""
    @Published var friends = [Friend]()
    @Published var showUserSearchSheet = false
    @Published var error: Error?
    @Published var modalError: Error?
    @Published var friendToBeRemoved: Friend? {
      didSet {
        showRemoveFriendConfirmation = true
      }
    }

    @Published var showRemoveFriendConfirmation = false
    @Published var showProfileQrCode = false

    let profile: Profile

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) {
      Task {
        switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
        case let .success(newFriend):
          withAnimation {
            self.friends.append(newFriend)
          }
          self.showUserSearchSheet = false
          onSuccess()
        case let .failure(error):
          logger.warning("failed add new friend '\(receiver)': \(error.localizedDescription)")
          self.modalError = error
        }
      }
    }

    func updateFriendRequest(friend: Friend, newStatus: Friend.Status) {
      let friendUpdate = Friend.UpdateRequest(
        sender: friend.sender,
        receiver: friend.receiver,
        status: newStatus
      )

      Task {
        switch await client.friend.update(id: friend.id, friendUpdate: friendUpdate) {
        case let .success(updatedFriend):
          withAnimation {
            if updatedFriend.status != Friend.Status.blocked {
              self.friends.replace(friend, with: updatedFriend)
            } else {
              self.friends.remove(object: friend)
            }
          }
        case let .failure(error):
          logger
            .warning(
              "failed to update friend request '\(friend.id)' with status '\(newStatus.rawValue)':\(error.localizedDescription)"
            )
          self.error = error
        }
      }
    }

    func removeFriendRequest(_ friend: Friend) {
      Task {
        switch await client.friend.delete(id: friend.id) {
        case .success:
          withAnimation {
            self.friends.remove(object: friend)
          }
          showRemoveFriendConfirmation = false
        case let .failure(error):
          logger.warning("failed to remove friend request '\(friend.id)': \(error.localizedDescription)")
          self.error = error
        }
      }
    }

    func loadFriends(currentUser: Profile) async {
      switch await client.friend.getByUserId(
        userId: profile.id,
        status: currentUser.id == profile.id ? .none : Friend.Status.accepted
      ) {
      case let .success(friends):
        self.friends = friends
      case let .failure(error):
        self.error = error
      }
    }
  }
}
