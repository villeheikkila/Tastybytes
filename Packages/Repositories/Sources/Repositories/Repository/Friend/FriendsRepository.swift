import Foundation
import Models

public protocol FriendRepository: Sendable {
    func getByUserId(userId: Profile.Id, status: Friend.Status?) async throws -> [Friend]
    func insert(newFriend: Friend.NewRequest) async throws -> Friend
    func update(id: Friend.Id, friendUpdate: Friend.UpdateRequest) async throws -> Friend
    func delete(id: Friend.Id) async throws
}
