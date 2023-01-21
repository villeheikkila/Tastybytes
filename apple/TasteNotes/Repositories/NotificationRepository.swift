import Foundation
import Supabase

protocol NotificationRepository {
  func getAll(afterId: Int?) async -> Result<[Notification], Error>
  func markRead(id: Int) async -> Result<Notification, Error>
  func markAllRead() async -> Result<Void, Error>
  func markAllFriendRequestsAsRead() async -> Result<[Notification], Error>
  func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Notification], Error>
  func delete(id: Int) async -> Result<Void, Error>
  func deleteAll() async -> Result<Void, Error>
}

struct SupabaseNotificationRepository: NotificationRepository {
  let client: SupabaseClient

  func getAll(afterId: Int? = nil) async -> Result<[Notification], Error> {
    do {
      let response: [Notification] = try await client
        .database
        .from(Notification.getQuery(.tableName))
        .select(columns: Notification.getQuery(.joined))
        .gt(column: "id", value: afterId ?? 0)
        .order(column: "id", ascending: false)
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func markRead(id: Int) async -> Result<Notification, Error> {
    do {
      let response: Notification = try await client
        .database
        .rpc(fn: "fnc__mark_notification_as_read", params: Notification.MarkReadRequest(id: id))
        .select(columns: Notification.getQuery(.joined))
        .limit(count: 1)
        .single()
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func markAllRead() async -> Result<Void, Error> {
    do {
      try await client
        .database
        .rpc(fn: "fnc__mark_all_notification_read")
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func markAllFriendRequestsAsRead() async -> Result<[Notification], Error> {
    do {
      let response: [Notification] = try await client
        .database
        .rpc(fn: "fnc__mark_friend_request_notification_as_read")
        .select(columns: Notification.getQuery(.joined))
        .execute()
        .value

      return .success(response)
    } catch {
      return .failure(error)
    }
  }

  func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Notification], Error> {
    do {
      let response: [Notification] = try await client
        .database
        .rpc(
          fn: "fnc__mark_check_in_notification_as_read",
          params: Notification.MarkCheckInReadRequest(checkInId: checkInId)
        )
        .select(columns: Notification.getQuery(.joined))
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
        .from(Notification.getQuery(.tableName))
        .delete()
        .eq(column: "id", value: id)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }

  func deleteAll() async -> Result<Void, Error> {
    do {
      try await client
        .database
        .from(Notification.getQuery(.tableName))
        .delete()
        // DELETE requires a where clause, add something that always returns true
        // Security policies make sure that everything can be deleted
        .neq(column: "id", value: 0)
        .execute()

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}
