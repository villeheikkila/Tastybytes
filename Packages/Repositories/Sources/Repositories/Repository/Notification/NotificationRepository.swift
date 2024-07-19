import Models

public protocol NotificationRepository: Sendable {
    func getAll(afterId: Int?) async throws -> [Models.Notification]
    func getUnreadCount() async throws -> Int
    func refreshPushNotificationToken(deviceToken: String) async throws -> Profile.PushNotification
    func updatePushNotificationSettingsForDevice(updateRequest: Profile.PushNotification) async throws -> Profile.PushNotification
    func markRead(id: Int) async throws -> Notification
    func markAllRead() async throws -> [Models.Notification]
    func markAllFriendRequestsAsRead() async throws -> [Models.Notification]
    func markAllCheckInNotificationsAsRead(checkInId: Int) async throws -> [Models.Notification]
    func delete(id: Int) async throws
    func deleteAll() async throws
}
