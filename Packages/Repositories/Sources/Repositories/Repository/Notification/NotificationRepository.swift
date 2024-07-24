import Models

public protocol NotificationRepository: Sendable {
    func getAll(afterId: Notification.Id?) async throws -> [Models.Notification.Joined]
    func getUnreadCount() async throws -> Int
    func refreshPushNotificationToken(deviceToken: String) async throws -> Profile.PushNotification
    func updatePushNotificationSettingsForDevice(updateRequest: Profile.PushNotification) async throws -> Profile.PushNotification
    func markRead(id: Notification.Id) async throws -> Notification.Joined
    func markAllRead() async throws -> [Models.Notification.Joined]
    func markAllFriendRequestsAsRead() async throws -> [Models.Notification.Joined]
    func markAllCheckInNotificationsAsRead(checkInId: CheckIn.Id) async throws -> [Models.Notification.Joined]
    func delete(id: Notification.Id) async throws
    func deleteAll() async throws
}
