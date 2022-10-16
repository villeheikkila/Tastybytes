import Foundation
import PostgREST

struct SupabaseFriendsRepository {
    private let database = Supabase.client.database
    private let tableName = "friends"
    private let savedLimited = "id, user_id_1, user_id_2, status"
    private let joined = "id, status, sender:user_id_1 (id, username, first_name, last_name, avatar_url), receiver:user_id_2 (id, username, first_name, last_name, avatar_url)"
    
    func loadByUserId(userId: UUID) async throws -> [Friend] {
        return try await database
            .from(tableName)
            .select(columns: joined)
            .or(filters: "user_id_1.eq.\(userId),user_id_2.eq.\(userId)")
            .not(column: "status", operator: .eq, value: FriendStatus.blocked.rawValue)
            .execute()
            .decoded(to: [Friend].self)
    }
    
    func insert(newFriend: NewFriend) async throws -> Friend {
        return try await database
            .from(tableName)
            .insert(values: newFriend, returning: .representation)
            .select(columns: joined)
            .single()
            .execute()
            .decoded(to: Friend.self)
    }
    
    func updateStatus(id: Int, friendUpdate: FriendUpdate) async throws -> Friend {
         return try await database
            .from(tableName)
            .update(values: friendUpdate, returning: .representation)
            .eq(column: "id", value: id)
            .select(columns: joined)
            .single()
            .execute()
            .decoded(to: Friend.self)
    }
    
    func delete(id: Int) async throws -> Void {
        try await database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .select(columns: savedLimited)
            .single()
            .execute()
    }
    
}
    


