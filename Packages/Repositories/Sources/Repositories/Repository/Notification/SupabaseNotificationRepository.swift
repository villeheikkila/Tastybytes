import Models
internal import Supabase

struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient

    func getAll(afterId: Int? = nil) async throws -> [Models.Notification] {
        try await client
            .from(.notifications)
            .select(Notification.getQuery(.joined))
            .gt("id", value: afterId ?? 0)
            .order("id", ascending: false)
            .execute()
            .value
    }

    func getUnreadCount() async throws -> Int {
        let response = try await client
            .from(.notifications)
            .select("id", head: true, count: .exact)
            .is("seen_at", value: nil)
            .execute()
            .count

        return response ?? 0
    }

    func refreshPushNotificationToken(deviceToken: String) async throws -> Profile.PushNotification {
        try await client
            .rpc(fn: .upsertDeviceToken, params: Profile.PushNotificationToken(deviceToken: deviceToken))
            .select(Profile.PushNotification.getQuery(.saved(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func updatePushNotificationSettingsForDevice(updateRequest: Profile.PushNotification) async throws -> Profile.PushNotification {
        try await client
            .from(.profilePushNotifications)
            .update(updateRequest, returning: .representation)
            .eq("device_token", value: updateRequest.id)
            .select(Profile.PushNotification.getQuery(.saved(false)))
            .single()
            .execute()
            .value
    }

    func markRead(id: Int) async throws -> Notification {
        try await client
            .rpc(fn: .markNotificationAsRead, params: Notification.MarkReadRequest(id: id))
            .select(Notification.getQuery(.joined))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func markAllRead() async throws -> [Models.Notification] {
        try await client
            .rpc(fn: .markAllNotificationRead)
            .select(Notification.getQuery(.joined))
            .execute()
            .value
    }

    func markAllFriendRequestsAsRead() async throws -> [Models.Notification] {
        try await client
            .rpc(fn: .markFriendRequestNotificationAsRead)
            .select(Notification.getQuery(.joined))
            .execute()
            .value
    }

    func markAllCheckInNotificationsAsRead(checkInId: Int) async throws -> [Models.Notification] {
        try await client
            .rpc(
                fn: .markCheckInNotificationAsRead,
                params: Notification.MarkCheckInReadRequest(checkInId: checkInId)
            )
            .select(Notification.getQuery(.joined))
            .execute()
            .value
    }

    func delete(id: Int) async throws {
        try await client
            .from(.notifications)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func deleteAll() async throws {
        try await client
            .from(.notifications)
            .delete()
            // DELETE requires a where clause, add something that always returns true
            // Security policies make sure that everything can be deleted
            .neq("id", value: 0)
            .execute()
    }
}
