import Models

public protocol NotificationRepository: Sendable {
    func getAll(profileId: Profile.Id, afterId: Notification.Id?) async throws -> [Models.Notification.Joined]
    func getUnreadCount(profileId: Profile.Id) async throws -> Int
    func refreshPushNotificationToken(deviceToken: DeviceToken.Id, isDebug: Bool) async throws -> Profile.PushNotificationSettings
    func updatePushNotificationSettingsForDevice(updateRequest: Profile.PushNotificationSettings) async throws
    func updateNotificationSettings(settings: Models.Notification.Settings) async throws
    func markRead(id: Notification.Id) async throws -> Notification.Joined
    func markUnread(id: Notification.Id) async throws -> Notification.Joined
    func markAllRead() async throws -> [Models.Notification.Joined]
    func markAllFriendRequestsAsRead() async throws -> [Models.Notification.Joined]
    func markAllCheckInNotificationsAsRead(checkInId: CheckIn.Id) async throws -> [Models.Notification.Joined]
    func delete(id: Notification.Id) async throws
    func deleteAll(profileId: Profile.Id) async throws
}
