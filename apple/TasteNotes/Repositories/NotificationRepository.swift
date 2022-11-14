import Foundation
import Supabase

protocol NotificationRepository {
    func getAll() async -> Result<[Notification], Error>
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
}
