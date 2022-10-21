import Foundation
import GoTrue
import SupabaseStorage
import Supabase
import Realtime

protocol NotificationRepository {
    func delete(id: Int) async throws -> Void
}

struct SupabaseNotificationRepository: NotificationRepository {
    let client: SupabaseClient
    private let tableName = "notifications"
    
    func delete(id: Int) async throws -> Void {
        try await client
            .database
            .from(tableName)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
    
}

