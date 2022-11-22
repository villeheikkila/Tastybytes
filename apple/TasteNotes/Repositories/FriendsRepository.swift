import Foundation
import PostgREST
import Supabase

protocol FriendRepository {
    func getByUserId(userId: UUID, status: Friend.Status?) async -> Result<[Friend], Error>
    func insert(newFriend: Friend.NewRequest) async -> Result<Friend, Error>
    func update(id: Int, friendUpdate: Friend.UpdateRequest) async -> Result<Friend, Error>
    func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient

    func getByUserId(userId: UUID, status: Friend.Status?) async -> Result<[Friend], Error> {
        do {
            var queryBuilder = client
                .database
                .from(Friend.getQuery(.tableName))
                .select(columns: Friend.getQuery(.joined(false)))
                .or(filters: "user_id_1.eq.\(userId),user_id_2.eq.\(userId)")

            if let status = status {
                queryBuilder = queryBuilder.eq(column: "status", value: status.rawValue)
            } else {
                queryBuilder = queryBuilder.not(column: "status", operator: .eq, value: Friend.Status.blocked.rawValue)
            }

            let response = try await queryBuilder
                .execute()
                .decoded(to: [Friend].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newFriend: Friend.NewRequest) async -> Result<Friend, Error> {
        do {
            let response = try await client
                .database
                .from(Friend.getQuery(.tableName))
                .insert(values: newFriend, returning: .representation)
                .select(columns: Friend.getQuery(.joined(false)))
                .single()
                .execute()
                .decoded(to: Friend.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(id: Int, friendUpdate: Friend.UpdateRequest) async -> Result<Friend, Error> {
        do {
            let response = try await client
                .database
                .from(Friend.getQuery(.tableName))
                .update(values: friendUpdate, returning: .representation)
                .eq(column: "id", value: id)
                .select(columns: Friend.getQuery(.joined(false)))
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
                .from(Friend.getQuery(.tableName))
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
