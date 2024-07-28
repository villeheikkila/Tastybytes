import Foundation
import Models
internal import Supabase

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient

    func getByUserId(id: Profile.Id, status: Friend.Status?) async throws -> [Friend.Saved] {
        var queryBuilder = client
            .from(.friends)
            .select(Friend.getQuery(.joined(false)))
            .or("user_id_1.eq.\(id),user_id_2.eq.\(id)")

        if let status {
            switch status {
            case .blocked:
                queryBuilder = queryBuilder.eq("status", value: status.rawValue)
                    .eq("blocked_by", value: id.rawValue)
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

    func getCurrentUserFriends() async throws -> [Friend.Saved] {
        try await client
            .from(.viewProfileFriends)
            .select(Friend.getQuery(.joined(false)))
            .execute()
            .value
    }

    func insert(newFriend: Friend.NewRequest) async throws -> Friend.Saved {
        try await client
            .from(.friends)
            .insert(newFriend, returning: .representation)
            .select(Friend.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }

    func update(id: Friend.Id, friendUpdate: Friend.UpdateRequest) async throws -> Friend.Saved {
        try await client
            .from(.friends)
            .update(friendUpdate, returning: .representation)
            .eq("id", value: id.rawValue)
            .select(Friend.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }

    func delete(id: Friend.Id) async throws {
        try await client
            .from(.friends)
            .delete()
            .eq("id", value: id.rawValue)
            .select()
            .single()
            .execute()
    }
}
