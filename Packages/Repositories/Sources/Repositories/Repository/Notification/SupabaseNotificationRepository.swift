import Models
internal import Supabase

struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient

    func getAll(profileId: Profile.Id, afterId: Notification.Id? = nil) async throws -> [Models.Notification.Joined] {
        try await client
            .from(.notifications)
            .select(Notification.getQuery(.joined(false)))
            .eq("profile_id", value: profileId.rawValue)
            .gt("id", value: afterId?.rawValue ?? 0)
            .order("id", ascending: false)
            .execute()
            .value
    }

    func getUnreadCount(profileId: Profile.Id) async throws -> Int {
        let response = try await client
            .from(.notifications)
            .select("id", head: true, count: .exact)
            .eq("profile_id", value: profileId.rawValue)
            .is("seen_at", value: nil)
            .execute()
            .count

        return response ?? 0
    }

    func refreshPushNotificationToken(deviceToken: DeviceToken.Id, isDebug: Bool) async throws -> Profile.PushNotificationSettings {
        try await client
            .rpc(
                fn: .upsertDeviceToken,
                params: Profile.PushNotificationToken(deviceToken: deviceToken, isDebug: isDebug)
            )
            .select(Profile.PushNotificationSettings.getQuery(.saved(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func updatePushNotificationSettingsForDevice(updateRequest: Profile.PushNotificationSettings) async throws {
        try await client
            .from(.profilePushNotifications)
            .update(updateRequest)
            .eq("device_token", value: updateRequest.deviceToken.rawValue)
            .eq("created_by", value: updateRequest.createdBy.uuidString)
            .execute()
    }

    func markRead(id: Notification.Id) async throws -> Notification.Joined {
        try await client
            .rpc(fn: .markNotificationAsRead, params: Notification.MarkReadRequest(id: id))
            .select(Notification.getQuery(.joined(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }

    func markAllRead() async throws -> [Models.Notification.Joined] {
        try await client
            .rpc(fn: .markAllNotificationRead)
            .select(Notification.getQuery(.joined(false)))
            .execute()
            .value
    }

    func markAllFriendRequestsAsRead() async throws -> [Models.Notification.Joined] {
        try await client
            .rpc(fn: .markFriendRequestNotificationAsRead)
            .select(Notification.getQuery(.joined(false)))
            .execute()
            .value
    }

    func markAllCheckInNotificationsAsRead(checkInId: CheckIn.Id) async throws -> [Models.Notification.Joined] {
        try await client
            .rpc(
                fn: .markCheckInNotificationAsRead,
                params: ["p_check_in_id": checkInId.rawValue]
            )
            .select(Notification.getQuery(.joined(false)))
            .execute()
            .value
    }

    func updateNotificationSettings(settings: Models.Notification.Settings) async throws {
        try await client
            .rpc(
                fn: .updateNotificationSettings,
                params: settings
            )
            .execute()
    }

    func delete(id: Notification.Id) async throws {
        try await client
            .from(.notifications)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func deleteAll(profileId: Profile.Id) async throws {
        try await client
            .from(.notifications)
            .delete()
            .eq("profile_id", value: profileId.rawValue)
            .execute()
    }
}
