import Foundation
import Models

public protocol FriendRepository: Sendable {
    func getByUserId(userId: UUID, status: Friend.Status?) async throws -> [Friend]
    func insert(newFriend: Friend.NewRequest) async throws -> Friend
    func update(id: Int, friendUpdate: Friend.UpdateRequest) async throws -> Friend
    func delete(id: Int) async throws
}
