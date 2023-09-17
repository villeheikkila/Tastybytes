import Models
import Supabase

public protocol NotificationRepository {
    func getAll(afterId: Int?) async -> Result<[Models.Notification], Error>
    func getUnreadCount() async -> Result<Int, Error>
    func refreshPushNotificationToken(token: Profile.PushNotificationToken) async
        -> Result<ProfilePushNotification, Error>
    func updatePushNotificationSettingsForDevice(updateRequest: ProfilePushNotification) async
        -> Result<ProfilePushNotification, Error>
    func markRead(id: Int) async -> Result<Notification, Error>
    func markAllRead() async -> Result<Void, Error>
    func markAllFriendRequestsAsRead() async -> Result<[Models.Notification], Error>
    func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Models.Notification], Error>
    func delete(id: Int) async -> Result<Void, Error>
    func deleteAll() async -> Result<Void, Error>
}

public struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient

    public func getAll(afterId: Int? = nil) async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .from(.notifications)
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

    public func getUnreadCount() async -> Result<Int, Error> {
        do {
            let response = try await client
                .database
                .from(.notifications)
                .select(columns: "id", head: true, count: .exact)
                .is(column: "seen_at", value: "null")
                .execute()
                .count

            return .success(response ?? 0)
        } catch {
            return .failure(error)
        }
    }

    public func refreshPushNotificationToken(token: Profile
        .PushNotificationToken) async -> Result<ProfilePushNotification, Error>
    {
        do {
            let response: ProfilePushNotification = try await client
                .database
                .rpc(fn: .upsertPushNotificationToken, params: token)
                .select(columns: ProfilePushNotification.getQuery(.saved(false)))
                .limit(count: 1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func updatePushNotificationSettingsForDevice(updateRequest: ProfilePushNotification) async
        -> Result<ProfilePushNotification, Error>
    {
        do {
            let response: ProfilePushNotification = try await client
                .database
                .from(.profilePushNotifications)
                .update(values: updateRequest, returning: .representation)
                .eq(column: "firebase_registration_token", value: updateRequest.id)
                .select(columns: ProfilePushNotification.getQuery(.saved(false)))
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func markRead(id: Int) async -> Result<Notification, Error> {
        do {
            let response: Notification = try await client
                .database
                .rpc(fn: .markNotificationAsRead, params: Notification.MarkReadRequest(id: id))
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

    public func markAllRead() async -> Result<Void, Error> {
        do {
            try await client
                .database
                .rpc(fn: .markAllNotificationRead)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func markAllFriendRequestsAsRead() async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .rpc(fn: .markFriendRequestNotificationAsRead)
                .select(columns: Notification.getQuery(.joined))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .rpc(
                    fn: .markCheckInNotificationAsRead,
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

    public func delete(id: Int) async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.notifications)
                .delete()
                .eq(column: "id", value: id)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }

    public func deleteAll() async -> Result<Void, Error> {
        do {
            try await client
                .database
                .from(.notifications)
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

public extension Notification {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.notifications.rawValue
        let saved = "id, message, created_at, seen_at"

        switch queryType {
        case .tableName:
            return tableName
        case .joined:
            return [
                saved,
                CheckInReaction.getQuery(.joinedProfileCheckIn(true)),
                Notification.CheckInTaggedProfiles.getQuery(.joined(true)),
                Friend.getQuery(.joined(true)),
                CheckInComment.getQuery(.joinedCheckIn(true)),
            ].joinComma()
        }
    }

    enum QueryType {
        case tableName
        case joined
    }
}

public extension ProfilePushNotification {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profilePushNotifications.rawValue
        let saved =
            "firebase_registration_token, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_friend_request_notifications, send_comment_notifications"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
