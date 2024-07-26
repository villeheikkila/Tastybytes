import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class FriendModel {
    private let logger = Logger(category: "FriendModel")
    public var friends = [Friend.Saved]()
    public var alertError: AlertEvent?
    public var isRefreshing = false
    public var state: ScreenState = .loading

    public var profile: Profile.Extended?

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public var acceptedFriends: [Profile.Saved] {
        guard let profile else { return [] }
        return friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: profile.id) }
    }

    public var blockedUsers: [Friend.Saved] {
        friends.filter { $0.status == .blocked }
    }

    public var acceptedOrPendingFriends: [Friend.Saved] {
        friends.filter { $0.status != .blocked }
    }

    public var pendingFriends: [Friend.Saved] {
        friends.filter { $0.status == .pending }
    }

    public func sendFriendRequest(receiver: Profile.Id, onSuccess: (() -> Void)? = nil) async {
        do {
            let newFriend = try await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending))
            withAnimation {
                self.friends.append(newFriend)
            }
            if let onSuccess {
                onSuccess()
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed add new friend '\(receiver)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateFriendRequest(friend: Friend.Saved, newStatus: Friend.Status) async {
        do {
            let updatedFriend = try await repository.friend.update(id: friend.id, friendUpdate: .init(
                sender: friend.sender,
                receiver: friend.receiver,
                status: newStatus
            ))
            withAnimation {
                self.friends.replace(friend, with: updatedFriend)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to update friend request. Error: \(error) (\(#file):\(#line))"
            )
        }
    }

    public func removeFriendRequest(_ friend: Friend.Saved) async {
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.friends.remove(object: friend)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to remove friend request '\(friend.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func hasNoFriendStatus(friend: Profile.Saved) -> Bool {
        guard let profile else { return false }
        return !friends.contains(where: { $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func isFriend(_ friend: Profile.Saved) -> Bool {
        guard let profile else { return false }
        return friends.contains(where: { $0.status == .accepted && $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func isPendingUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        guard let profile else { return nil }
        return friends.first(where: { $0.status == .pending && $0.getFriend(userId: profile.id).id == friend.id })
    }

    public func isPendingCurrentUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        guard profile != nil else { return nil }
        return friends.first(where: { $0.status == .pending && $0.sender == friend })
    }

    public func refresh(withHaptics: Bool = false) async {
        guard let profile else { return }
        if withHaptics {
            isRefreshing = true
        }
        do {
            let friends = try await repository.friend.getByUserId(id: profile.id, status: .none)
            self.friends = friends
            state = .populated
        } catch {
            if state != .populated {
                state = .error(error)
            }
            logger.error("Failed to load friends for current user. Error: \(error) (\(#file):\(#line))")
        }
        if withHaptics {
            isRefreshing = false
        }
    }

    public func initialize(profile: Profile.Extended) async {
        logger.info("Initializing friend manager")
        self.profile = profile
        await refresh()
    }

    public func unblockUser(_ friend: Friend.Saved) async {
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.friends.remove(object: friend)
            }
            logger.notice("\(friend.id) unblocked")
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to unblock user \(friend.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func blockUser(user: Profile.Saved, onSuccess: @escaping () -> Void) async {
        guard let profile else { return }
        if let friend = friends.first(where: { $0.getFriend(userId: profile.id) == user }) {
            await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
        } else {
            do {
                let blockedUser = try await repository.friend.insert(newFriend: .init(receiver: user.id, status: .blocked))
                withAnimation {
                    self.friends.append(blockedUser)
                }
                onSuccess()
            } catch {
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to block user \(user.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
