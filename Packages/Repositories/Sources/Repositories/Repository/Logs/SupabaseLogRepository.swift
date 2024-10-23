import Models
internal import Supabase
import Foundation

struct SupabaseLogRepository: LogRepository {
    let client: SupabaseClient

    func insertLogs(entries: [LogEntry]) async throws {
        try await client
            .from(.logs)
            .insert(entries)
            .execute()
            .value
    }
}
