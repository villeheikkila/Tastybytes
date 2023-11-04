import Models
import Supabase

struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient

    func getAll(afterId: Int? = nil) async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .from(.notifications)
                .select(Notification.getQuery(.joined))
                .gt("id", value: afterId ?? 0)
                .order("id", ascending: false)
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func getUnreadCount() async -> Result<Int, Error> {
        do {
            let response = try await client
                .database
                .from(.notifications)
                .select("id", head: true, count: .exact)
                .is("seen_at", value: "null")
                .execute()
                .count

            return .success(response ?? 0)
        } catch {
            return .failure(error)
        }
    }

    func refreshPushNotificationToken(deviceToken: String) async -> Result<ProfilePushNotification, Error> {
        do {
            let response: ProfilePushNotification = try await client
                .database
                .rpc(fn: .upsertDeviceToken, params: Profile
                    .PushNotificationToken(deviceToken: deviceToken))
                .select(ProfilePushNotification.getQuery(.saved(false)))
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func updatePushNotificationSettingsForDevice(updateRequest: ProfilePushNotification) async
        -> Result<ProfilePushNotification, Error>
    {
        do {
            let response: ProfilePushNotification = try await client
                .database
                .from(.profilePushNotifications)
                .update(updateRequest, returning: .representation)
                .eq("device_token", value: updateRequest.id)
                .select(ProfilePushNotification.getQuery(.saved(false)))
                .single()
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
                .rpc(fn: .markNotificationAsRead, params: Notification.MarkReadRequest(id: id))
                .select(Notification.getQuery(.joined))
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func markAllRead() async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .rpc(fn: .markAllNotificationRead)
                .select(Notification.getQuery(.joined))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func markAllFriendRequestsAsRead() async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .rpc(fn: .markFriendRequestNotificationAsRead)
                .select(Notification.getQuery(.joined))
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    func markAllCheckInNotificationsAsRead(checkInId: Int) async -> Result<[Models.Notification], Error> {
        do {
            let response: [Models.Notification] = try await client
                .database
                .rpc(
                    fn: .markCheckInNotificationAsRead,
                    params: Notification.MarkCheckInReadRequest(checkInId: checkInId)
                )
                .select(Notification.getQuery(.joined))
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
                .from(.notifications)
                .delete()
                .eq("id", value: id)
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
                .from(.notifications)
                .delete()
                // DELETE requires a where clause, add something that always returns true
                // Security policies make sure that everything can be deleted
                .neq("id", value: 0)
                .execute()

            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
