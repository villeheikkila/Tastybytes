import Foundation
import Models
internal import Supabase

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient

    func getByUserId(userId: UUID, status: Friend.Status?) async throws -> [Friend] {
        var queryBuilder = client
            .from(.friends)
            .select(Friend.getQuery(.joined(false)))
            .or("user_id_1.eq.\(userId),user_id_2.eq.\(userId)")

        if let status {
            switch status {
            case .blocked:
                queryBuilder = queryBuilder.eq("status", value: status.rawValue)
                    .eq("blocked_by", value: userId)
            case .accepted:
                queryBuilder = queryBuilder.eq("status", value: status.rawValue)
            default:
                ()
            }
        }

        return try await queryBuilder
            .execute()
            .value
    }

    func insert(newFriend: Friend.NewRequest) async throws -> Friend {
        try await client
            .from(.friends)
            .insert(newFriend, returning: .representation)
            .select(Friend.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }

    func update(id: Int, friendUpdate: Friend.UpdateRequest) async throws -> Friend {
        try await client
            .from(.friends)
            .update(friendUpdate, returning: .representation)
            .eq("id", value: id)
            .select(Friend.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.friends)
            .delete()
            .eq("id", value: id)
            .select()
            .single()
            .execute()
    }
}
