import Foundation
import Models

public protocol FriendRepository: Sendable {
    func getByUserId(userId: UUID, status: Friend.Status?) async -> Result<[Friend], Error>
    func insert(newFriend: Friend.NewRequest) async -> Result<Friend, Error>
    func update(id: Int, friendUpdate: Friend.UpdateRequest) async -> Result<Friend, Error>
    func delete(id: Int) async -> Result<Void, Error>
}
