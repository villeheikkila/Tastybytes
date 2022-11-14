import Foundation
import PostgREST
import Supabase

protocol FriendRepository {
    func getByUserId(userId: UUID, status: FriendStatus?) async -> Result<[Friend], Error>
    func insert(newFriend: NewFriend) async -> Result<Friend, Error>
    func update(id: Int, friendUpdate: FriendUpdate) async -> Result<Friend, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient
    private let tableName = Friend.getQuery(.tableName)
    private let joined = Friend.getQuery(.joined(false))

    func getByUserId(userId: UUID, status: FriendStatus?) async -> Result<[Friend], Error> {
        do {
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

            let response = try await queryBuilder
                .execute()
                .decoded(to: [Friend].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newFriend: NewFriend) async -> Result<Friend, Error> {
        do {
            let response = try await client
                .database
                .from(tableName)
                .insert(values: newFriend, returning: .representation)
                .select(columns: joined)
                .single()
                .execute()
                .decoded(to: Friend.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(id: Int, friendUpdate: FriendUpdate) async -> Result<Friend, Error> {
        do {
            let response = try await client
                .database
                .from(tableName)
                .update(values: friendUpdate, returning: .representation)
                .eq(column: "id", value: id)
                .select(columns: joined)
                .single()
                .execute()
                .decoded(to: Friend.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(tableName)
                .delete()
                .eq(column: "id", value: id)
                .select()
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
