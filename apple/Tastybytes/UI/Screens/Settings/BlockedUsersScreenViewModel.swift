import SwiftUI

extension BlockedUsersScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BlockedUsersScreenView")
    let client: Client
    @Published var blockedUsers = [Friend]()
    @Published var error: Error?
    @Published var showUserSearchSheet = false

    init(_ client: Client) {
      self.client = client
    }

    func unblockUser(_ friend: Friend) {
      Task {
        switch await client.friend.delete(id: friend.id) {
        case .success:
          withAnimation {
            self.blockedUsers.remove(object: friend)
          }
        case let .failure(error):
          logger.warning("failed to unblock user \(friend.id): \(error.localizedDescription)")
          self.error = error
        }
      }
    }

    func blockUser(user: Profile, onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) {
      Task {
        switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
        case let .success(blockedUser):
          withAnimation {
            self.blockedUsers.append(blockedUser)
          }
          onSuccess()
        case let .failure(error):
          logger.warning("failed to block user \(user.id): \(error.localizedDescription)")
          onFailure(error.localizedDescription)
        }
      }
    }

    func loadBlockedUsers(userId: UUID?) {
      if let userId {
        Task {
          switch await client.friend.getByUserId(userId: userId, status: .blocked) {
          case let .success(blockedUsers):
            withAnimation {
              self.blockedUsers = blockedUsers
            }
          case let .failure(error):
            logger.warning("failed to load blocked users: \(error.localizedDescription)")
            self.error = error
          }
        }
      }
    }
  }
}
