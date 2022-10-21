import Foundation
import PostgREST
import Supabase

protocol FriendRepository {
    func getByUserId(userId: UUID, status: FriendStatus?) async throws -> [Friend]
    func insert(newFriend: NewFriend) async throws -> Friend
    func update(id: Int, friendUpdate: FriendUpdate) async throws -> Friend
    func delete(id: Int) async throws -> Void
}

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient
    private let tableName = "friends"
    private let savedLimited = "id, user_id_1, user_id_2, status"
    private let joined = "id, status, sender:user_id_1 (id, username, first_name, last_name, avatar_url, name_display), receiver:user_id_2 (id, username, first_name, last_name, avatar_url, name_display)"

    func getByUserId(userId: UUID, status: FriendStatus? = nil) async throws -> [Friend] {
        var queryBuilder = client
            .database
            .from(tableName)
            .select(columns: joined)
            .or(filters: "user_id_1.eq.\(userId),user_id_2.eq.\(userId)")
        
        if let status = status {
            queryBuilder = queryBuilder.eq(column: "status", value: status.rawValue)
        } else {
            queryBuilder = queryBuilder.not(column: "status", operator: .eq, value: FriendStatus.blocked.rawValue)
        }
        
        return try await queryBuilder
            .execute()
            .decoded(to: [Friend].self)
    }

    func insert(newFriend: NewFriend) async throws -> Friend {
        return try await client
            .database
            .from(tableName)
            .insert(values: newFriend, returning: .representation)
            .select(columns: joined)
            .single()
            .execute()
            .decoded(to: Friend.self)
    }
    
    func update(id: Int, friendUpdate: FriendUpdate) async throws -> Friend {
         return try await client
            .database
            .from(tableName)
            .update(values: friendUpdate, returning: .representation)
            .eq(column: "id", value: id)
            .select(columns: joined)
            .single()
            .execute()
            .decoded(to: Friend.self)
    }
    
    func delete(id: Int) async throws -> Void {
        try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .select(columns: savedLimited)
            .single()
            .execute()
    }
    
}
    


