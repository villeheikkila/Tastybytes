import Observation
import OSLog
import SwiftUI

@Observable
final class FriendManager {
    private let logger = Logger(category: "FriendsScreen")
    var friends = [Friend]()

    var profile: Profile? = nil

    private let repository: Repository
    private let feedbackManager: FeedbackManager

    init(repository: Repository, feedbackManager: FeedbackManager) {
        self.repository = repository
        self.feedbackManager = feedbackManager
    }

    var acceptedFriends: [Profile] {
        guard let profile else { return [] }
        return friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: profile.id) }
    }

    var blockedUsers: [Friend] {
        friends.filter { $0.status == .blocked }
    }

    var acceptedOrPendingFriends: [Friend] {
        friends.filter { $0.status != .blocked }
    }

    var pendingFriends: [Friend] {
        friends.filter { $0.status == .pending }
    }

    func sendFriendRequest(receiver: UUID, onSuccess: (() -> Void)? = nil) async {
        switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
        case let .success(newFriend):
            await MainActor.run {
                withAnimation {
                    self.friends.append(newFriend)
                }
            }
            feedbackManager.toggle(.success("Friend Request Sent!"))
            if let onSuccess {
                onSuccess()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
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
            await MainActor.run {
                withAnimation {
                    withAnimation {
                        self.friends.replace(friend, with: updatedFriend)
                    }
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.warning(
                "failed to update friend request: \(error.localizedDescription)"
            )
        }
    }

    func removeFriendRequest(_ friend: Friend) async {
        switch await repository.friend.delete(id: friend.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.friends.remove(object: friend)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to remove friend request '\(friend.id)': \(error.localizedDescription)")
        }
    }

    func hasNoFriendStatus(friend: Profile) -> Bool {
        guard let profile else { return false }
        return !friends.contains(where: { $0.getFriend(userId: profile.id).id == friend.id })
    }

    func isFriend(_ friend: Profile) -> Bool {
        guard let profile else { return false }
        return friends.contains(where: { $0.status == .accepted && $0.getFriend(userId: profile.id).id == friend.id })
    }

    func isPendingUserApproval(_ friend: Profile) -> Friend? {
        guard let profile else { return nil }
        return friends.first(where: { $0.status == .pending && $0.getFriend(userId: profile.id).id == friend.id })
    }

    func refresh(withFeedback: Bool = false) async {
        guard let profile else { return }
        switch await repository.friend.getByUserId(
            userId: profile.id,
            status: .none
        ) {
        case let .success(friends):
            await MainActor.run {
                self.friends = friends
            }
            if withFeedback {
                feedbackManager.trigger(.notification(.success))
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to load friends for current user: \(error.localizedDescription)")
        }
    }

    func initialize(profile: Profile) async {
        logger.info("initializing friend manager")
        self.profile = profile
        await refresh()
    }

    func unblockUser(_ friend: Friend) async {
        switch await repository.friend.delete(id: friend.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.friends.remove(object: friend)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to unblock user \(friend.id): \(error.localizedDescription)")
        }
    }

    func blockUser(user: Profile, onSuccess: @escaping () -> Void) async {
        guard let profile else { return }
        if let friend = friends.first(where: { $0.getFriend(userId: profile.id) == user }) {
            await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
        } else {
            switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
            case let .success(blockedUser):
                await MainActor.run {
                    withAnimation {
                        self.friends.append(blockedUser)
                    }
                }
                onSuccess()
            case let .failure(error):
                guard !error.localizedDescription.contains("cancelled") else { return }
                feedbackManager.toggle(.error(.unexpected))
                logger.error("failed to block user \(user.id): \(error.localizedDescription)")
            }
        }
    }
}
