import Foundation
import Models
internal import Supabase

struct SupabaseAdminRepository: AdminRepository {
    let client: SupabaseClient

    func getAdminEventFeed() async throws -> [AdminEvent] {
        try await client
            .from(.adminEvents)
            .select(AdminEvent.getQuery(.joined(false)))
            .is("reviewed_at", value: nil)
            .order("id", ascending: false)
            .execute()
            .value
    }

    func markAdminEventAsReviewed(event: AdminEvent) async throws {
        try await client
            .rpc(fn: .markAdminEventAsReviewed, params: ["p_event_id": event.id])
            .execute()
    }
}
