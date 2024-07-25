import Foundation
import Models
internal import Supabase

struct SupabaseReportRepository: ReportRepository {
    let client: SupabaseClient

    func getAll() async throws -> [Report.Joined] {
        try await client
            .from(.reports)
            .select(Report.getQuery(.joined(false)))
            .is("resolved_at", value: nil)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func insert(report: Report.NewRequest) async throws {
        try await client
            .from(.reports)
            .insert(report, returning: .none)
            .execute()
    }

    func delete(id: Report.Id) async throws {
        try await client
            .from(.reports)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func resolve(id: Report.Id) async throws -> Report.Joined {
        try await client
            .from(.reports)
            .update(Report.ResolveRequest(resolvedAt: Date.now))
            .eq("id", value: id.rawValue)
            .select(Report.getQuery(.joined(false)))
            .single()
            .execute()
            .value
    }
}
