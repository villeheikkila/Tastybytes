import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class FriendEnvironmentModel {
    private let logger = Logger(category: "FriendsScreen")
    public var friends = [Friend]()
    public var alertError: AlertError?
    public var isRefreshing = false

    public var profile: Profile?

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public var acceptedFriends: [Profile] {
        guard let profile else { return [] }
        return friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: profile.id) }
    }

    public var blockedUsers: [Friend] {
        friends.filter { $0.status == .blocked }
    }

    public var acceptedOrPendingFriends: [Friend] {
        friends.filter { $0.status != .blocked }
    }

    public var pendingFriends: [Friend] {
        friends.filter { $0.status == .pending }
    }

    public func sendFriendRequest(receiver: UUID, onSuccess: (() -> Void)? = nil) async {
        switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
        case let .success(newFriend):
            await MainActor.run {
                withAnimation {
                    self.friends.append(newFriend)
                }
            }
            if let onSuccess {
                onSuccess()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed add new friend '\(receiver)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateFriendRequest(friend: Friend, newStatus: Friend.Status) async {
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to update friend request. Error: \(error) (\(#file):\(#line))"
            )
        }
    }

    public func removeFriendRequest(_ friend: Friend) async {
        switch await repository.friend.delete(id: friend.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.friends.remove(object: friend)
                }
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to remove friend request '\(friend.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func hasNoFriendStatus(friend: Profile) -> Bool {
        guard let profile else { return false }
        return !friends.contains(where: { $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func isFriend(_ friend: Profile) -> Bool {
        guard let profile else { return false }
        return friends.contains(where: { $0.status == .accepted && $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func isPendingUserApproval(_ friend: Profile) -> Friend? {
        guard let profile else { return nil }
        return friends.first(where: { $0.status == .pending && $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func refresh(withHaptics: Bool = false) async {
        guard let profile else { return }
        if withHaptics {
            isRefreshing = true
        }
        switch await repository.friend.getByUserId(
            userId: profile.id,
            status: .none
        ) {
        case let .success(friends):
            await MainActor.run {
                self.friends = friends
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load friends for current user. Error: \(error) (\(#file):\(#line))")
        }
        if withHaptics {
            isRefreshing = false
        }
    }

    public func initialize(profile: Profile) async {
        logger.info("Initializing friend manager")
        self.profile = profile
        await refresh()
    }

    public func unblockUser(_ friend: Friend) async {
        switch await repository.friend.delete(id: friend.id) {
        case .success:
            await MainActor.run {
                withAnimation {
                    self.friends.remove(object: friend)
                }
            }
            logger.notice("Friend manager initialized")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to unblock user \(friend.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func blockUser(user: Profile, onSuccess: @MainActor @Sendable @escaping () -> Void) async {
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
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to block user \(user.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
