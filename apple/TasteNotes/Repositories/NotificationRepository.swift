import Foundation
import Supabase

protocol NotificationRepository {
    func getAll() async -> Result<[Notification], Error>
    func markRead(id: Int) async -> Result<Notification, Error>
    func markAllFriendRequestsAsRead() async -> Result<[Notification], Error>
    func delete(id: Int) async -> Result<Void, Error>
}

struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient

    func getAll() async -> Result<[Notification], Error> {
        do {
            let response = try await client
                .database
                .from(Notification.getQuery(.tableName))
                .select(columns: Notification.getQuery(.joined))
                .execute()
                .decoded(to: [Notification].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func markRead(id: Int) async -> Result<Notification, Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__mark_notification_as_read", params: Notification.MarkReadRequest(id: id))
                .select(columns: Notification.getQuery(.joined))
                .limit(count: 1)
                .single()
                .execute()
                .decoded(to: Notification.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func markAllFriendRequestsAsRead() async -> Result<[Notification], Error> {
        do {
            let response = try await client
                .database
                .rpc(fn: "fnc__mark_friend_request_notification_as_read")
                .select(columns: Notification.getQuery(.joined))
                .execute()
                .decoded(to: [Notification].self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(Notification.getQuery(.tableName))
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
}
