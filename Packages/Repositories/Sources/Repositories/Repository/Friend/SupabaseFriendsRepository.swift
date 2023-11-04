import Foundation
import Models
import Supabase

struct SupabaseFriendsRepository: FriendRepository {
    let client: SupabaseClient

    func getByUserId(userId: UUID, status: Friend.Status?) async -> Result<[Friend], Error> {
        do {
            var queryBuilder = await client
                .database
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

            let response: [Friend] = try await queryBuilder
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func insert(newFriend: Friend.NewRequest) async -> Result<Friend, Error> {
        do {
            let response: Friend = try await client
                .database
                .from(.friends)
                .insert(newFriend, returning: .representation)
                .select(Friend.getQuery(.joined(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func update(id: Int, friendUpdate: Friend.UpdateRequest) async -> Result<Friend, Error> {
        do {
            let response: Friend = try await client
                .database
                .from(.friends)
                .update(friendUpdate, returning: .representation)
                .eq("id", value: id)
                .select(Friend.getQuery(.joined(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.friends)
                .delete()
                .eq("id", value: id)
                .select()
                .single()
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
