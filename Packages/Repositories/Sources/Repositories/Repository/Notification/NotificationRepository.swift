import Models

public protocol NotificationRepository {
    func getAll(afterId: Int?) async -> Result<[Models.Notification], Error>
    func getUnreadCount() async -> Result<Int, Error>
    func refreshPushNotificationToken(deviceToken: String) async
        -> Result<ProfilePushNotification, Error>
    func updatePushNotificationSettingsForDevice(updateRequest: ProfilePushNotification) async
        -> Result<ProfilePushNotification, Error>
    func markRead(id: Int) async -> Result<Notification, Error>
    func markAllRead() async -> Result<[Models.Notification], Error>
    func markAllFriendRequestsAsRead() async -> Result<[Models.Notification], Error>
    func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Models.Notification], Error>
    func delete(id: Int) async -> Result<Void, Error>
    func deleteAll() async -> Result<Void, Error>
}
